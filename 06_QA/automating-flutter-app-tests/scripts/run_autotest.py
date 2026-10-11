#!/usr/bin/env python3
"""Run L1 / L2 / L3 automated tests for a Flutter iOS app and draft autotest-report.md.

L1  flutter analyze + flutter test (quality harness: guidelines, text scale, VoiceOver, interruption)
L2  flutter drive on a simulator: main-loop targets x N rounds, then the QA probe with
    photos granted and denied (notifications pre-granted once per drive via applesimutils)
L3  flutter drive --profile on a physical iPhone (optional; or deferred with user confirmation)

Results are parsed from `QA ...` lines printed by assets/integration_support/qa_log.dart.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import shutil
import statistics
import subprocess
import sys
import time
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
TEMPLATE = SKILL_DIR / "assets" / "autotest-report-template.md"
DRIVER_ASSET = SKILL_DIR / "assets" / "test_driver" / "integration_test.dart"

SIM_FIRST_SCREEN_MS = 2000
DEVICE_FIRST_SCREEN_MS = 1000
SIM_OVER16_RATIO = 0.10
DEVICE_OVER16_RATIO = 0.01
DEVICE_BUILD_P90_MS = 8.0
STORE_TIMEOUT_MS = 20000
PERMISSION_SETTLE_S = 8

ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
RE_FIRST = re.compile(r"QA first screen: (\d+) ms")
RE_PERF = re.compile(
    r"QA perf (.+?): frames=(\d+) build p50=([\d.]+) p90=([\d.]+) max=([\d.]+)ms; "
    r"raster p90=([\d.]+) max=([\d.]+)ms; over16ms=(\d+)"
)
RE_PERF_EMPTY = re.compile(r"QA perf (.+?): no frames")
RE_NOTIF = re.compile(r"QA notifications planned=(\d+) pending=(\d+)")
RE_ALBUM = re.compile(r"QA album\((\w+)\) -> (\w+)")
RE_STORE = re.compile(r"QA store buy started=(true|false) in (\d+) ms")
RE_TIMING = re.compile(r"QA timing (.+?): (\d+) ms")
RE_LEGACY_EXPORT = re.compile(r"\bexport render: (\d+) ms")
RE_SKIP = re.compile(r"QA skip (\w+): (.+)$")
RE_TEST_SUMMARY = re.compile(
    r"\+(\d+)(?: ~(\d+))?(?: -(\d+))?: (All tests passed!|Some tests failed\.)"
)
L1_CATEGORIES = (
    ("无障碍指南", "可点元素有标签、≥44pt、对比度达标"),
    ("动态字体", "×1.35 / ×2.0 无溢出"),
    ("VoiceOver", "主路径语义：标签、按钮、选中态"),
    ("弱网与中断", "端口断开降级、切后台存草稿"),
)


def log(message: str) -> None:
    print(f"[autotest] {message}", flush=True)


# ---------------------------------------------------------------- processes


def run(
    cmd: list[str],
    cwd: Path,
    log_path: Path,
    env: dict[str, str] | None = None,
    timeout: int = 1800,
) -> tuple[int, str, float]:
    log(f"$ {' '.join(cmd)}")
    started = time.monotonic()
    merged_env = {**os.environ, **(env or {})}
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            env=merged_env,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout,
        )
        code, output = result.returncode, result.stdout
    except subprocess.TimeoutExpired as error:
        raw = error.stdout or ""
        output = raw.decode(errors="replace") if isinstance(raw, bytes) else raw
        code, output = 124, output + f"\n[autotest] timeout after {timeout}s\n"
    seconds = time.monotonic() - started
    output = ANSI.sub("", output)
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(output, encoding="utf-8")
    for line in output.splitlines():
        if "QA " in line or RE_TEST_SUMMARY.search(line):
            print(f"    {line.strip()}", flush=True)
    log(f"exit={code} in {seconds:.0f}s, log: {log_path}")
    return code, output, seconds


def quiet(cmd: list[str], timeout: int = 120) -> tuple[int, str]:
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    except (OSError, subprocess.TimeoutExpired) as error:
        return 1, str(error)
    return result.returncode, (result.stdout + result.stderr).strip()


# ---------------------------------------------------------------- parsing


def parse_metrics(text: str) -> dict:
    metrics: dict = {
        "first_screen_ms": None,
        "perf": {},
        "notifications": None,
        "album": None,
        "store": None,
        "timings": {},
        "skips": {},
    }
    for line in text.splitlines():
        if match := RE_FIRST.search(line):
            metrics["first_screen_ms"] = int(match[1])
        elif match := RE_PERF.search(line):
            metrics["perf"][match[1]] = {
                "frames": int(match[2]),
                "build_p50": float(match[3]),
                "build_p90": float(match[4]),
                "build_max": float(match[5]),
                "raster_p90": float(match[6]),
                "raster_max": float(match[7]),
                "over16": int(match[8]),
            }
        elif match := RE_PERF_EMPTY.search(line):
            metrics["perf"][match[1]] = {"frames": 0}
        elif match := RE_NOTIF.search(line):
            metrics["notifications"] = {
                "planned": int(match[1]),
                "pending": int(match[2]),
            }
        elif match := RE_ALBUM.search(line):
            outcome = "denied" if "denied" in match[2].lower() else match[2]
            metrics["album"] = {"permission": match[1], "outcome": outcome}
        elif match := RE_STORE.search(line):
            metrics["store"] = {"started": match[1] == "true", "ms": int(match[2])}
        elif match := RE_TIMING.search(line):
            metrics["timings"][match[1]] = int(match[2])
        elif match := RE_LEGACY_EXPORT.search(line):
            metrics["timings"]["export render"] = int(match[1])
        elif match := RE_SKIP.search(line):
            metrics["skips"][match[1]] = match[2].strip()
    return metrics


def parse_flutter_test(text: str) -> dict:
    """Parse `flutter test --reporter json` events (one JSON object per line)."""
    started: dict[int, str] = {}
    names: set[str] = set()
    failed_names: set[str] = set()
    passed = failed = skipped = 0
    success = False
    for raw in text.splitlines():
        raw = raw.strip()
        if not raw.startswith("{"):
            continue
        try:
            event = json.loads(raw)
        except json.JSONDecodeError:
            continue
        kind = event.get("type")
        if kind == "testStart":
            started[event["test"]["id"]] = event["test"]["name"]
        elif kind == "testDone" and not event.get("hidden"):
            name = started.get(event["testID"], "")
            names.add(name)
            if event.get("skipped"):
                skipped += 1
            elif event.get("result") == "success":
                passed += 1
            else:
                failed += 1
                failed_names.add(name)
        elif kind == "done":
            success = bool(event.get("success"))
    return {
        "passed": passed,
        "skipped": skipped,
        "failed": failed,
        "all_passed": success and failed == 0 and passed > 0,
        "names": sorted(names),
        "failed_names": sorted(failed_names),
    }


# ---------------------------------------------------------------- project


def find_project_root(app_dir: Path) -> Path:
    for candidate in [app_dir, *app_dir.parents][:5]:
        if (candidate / "docs" / "workflow").is_dir():
            return candidate
    return app_dir


def detect_bundle_id(app_dir: Path) -> str | None:
    pbxproj = app_dir / "ios" / "Runner.xcodeproj" / "project.pbxproj"
    if not pbxproj.exists():
        return None
    ids = {
        value.strip().strip('"')
        for value in re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);", pbxproj.read_text())
    }
    ids = {i for i in ids if not i.endswith(".RunnerTests") and "$(" not in i}
    return ids.pop() if len(ids) == 1 else None


def detect_simulator() -> str | None:
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from detect_test_targets import list_simulators

    ready = [s for s in list_simulators(include_shutdown=False) if "iPhone" in s["name"]]
    return ready[0]["id"] if ready else None


def pubspec_name(app_dir: Path) -> str:
    match = re.search(r"^name:\s*(\S+)", (app_dir / "pubspec.yaml").read_text(), re.M)
    return match[1] if match else app_dir.name


def git_commit(app_dir: Path) -> str:
    code, output = quiet(["git", "-C", str(app_dir), "rev-parse", "--short", "HEAD"])
    if code != 0:
        return "-"
    dirty_code, dirty = quiet(["git", "-C", str(app_dir), "status", "--porcelain"])
    return output + (" (含未提交改动)" if dirty_code == 0 and dirty else "")


# ---------------------------------------------------------------- simulator permissions


def grant_notifications(udid: str, bundle: str) -> bool:
    if not shutil.which("applesimutils"):
        log("applesimutils 未安装：通知只能验证排程逻辑（pending 可能为 0）")
        return False
    code, output = quiet(
        [
            "applesimutils",
            "--byId",
            udid,
            "--bundle",
            bundle,
            "--setPermissions",
            "notifications=YES",
        ],
        timeout=120,
    )
    if code != 0:
        log(f"applesimutils 失败：{output}")
        return False
    log(f"已授予通知权限，等待 SpringBoard 恢复 {PERMISSION_SETTLE_S}s")
    time.sleep(PERMISSION_SETTLE_S)
    return True


def set_photos(udid: str, bundle: str, service: str, grant: bool) -> None:
    action = "grant" if grant else "revoke"
    code, output = quiet(["xcrun", "simctl", "privacy", udid, action, service, bundle])
    if code != 0:
        log(f"simctl privacy {action} {service} 失败：{output}")


# ---------------------------------------------------------------- judgement


def row(item: str, expected: str, actual: str, result: str) -> dict:
    return {"item": item, "expected": expected, "actual": actual, "result": result}


def judge_system(metrics: dict, expected_album: str | None, on_device: bool) -> list[dict]:
    rows = []
    skips = metrics["skips"]

    notif = metrics["notifications"]
    if notif:
        ok = notif["planned"] > 0 and notif["pending"] == notif["planned"]
        actual = f"planned={notif['planned']} pending={notif['pending']}"
        rows.append(row("通知待发队列", "pending == planned > 0", actual, "PASS" if ok else "FAIL"))
    elif "notifications" in skips:
        rows.append(row("通知待发队列", "-", skips["notifications"], "SKIP"))
    else:
        rows.append(row("通知待发队列", "pending == planned > 0", "无输出", "FAIL"))

    album = metrics["album"]
    if album:
        want = "saved" if album["permission"] == "granted" else "denied"
        if expected_album and album["permission"] != expected_album:
            rows.append(row(f"相册（{expected_album}）", want, f"探针读到 {album['permission']}", "FAIL"))
        else:
            result = "PASS" if album["outcome"] == want else "FAIL"
            rows.append(row(f"相册（{album['permission']}）", want, album["outcome"], result))
    elif "album" in skips:
        rows.append(row("相册", "-", skips["album"], "SKIP"))
    else:
        rows.append(row("相册", "saved / denied", "无输出", "FAIL"))

    store = metrics["store"]
    if store:
        if on_device:
            ok = store["ms"] < STORE_TIMEOUT_MS
            expected = f"{STORE_TIMEOUT_MS} ms 内返回"
        else:
            ok = not store["started"] and store["ms"] < STORE_TIMEOUT_MS
            expected = f"不可购买降级，{STORE_TIMEOUT_MS} ms 内返回"
        actual = f"started={str(store['started']).lower()} {store['ms']} ms"
        rows.append(row("商店", expected, actual, "PASS" if ok else "FAIL"))
    elif "store" in skips:
        rows.append(row("商店", "-", skips["store"], "SKIP"))
    else:
        rows.append(row("商店", "超时内返回", "无输出", "FAIL"))

    for label, ms in metrics["timings"].items():
        rows.append(row(label, "记录", f"{ms} ms", "PASS"))
    return rows


def judge_perf(perf: dict, on_device: bool) -> list[dict]:
    rows = []
    for action, data in perf.items():
        frames = data.get("frames", 0)
        if frames == 0:
            rows.append({"action": action, "frames": 0, "result": "WARN"})
            continue
        ratio = data["over16"] / frames
        if on_device:
            ok = ratio <= DEVICE_OVER16_RATIO and data["build_p90"] <= DEVICE_BUILD_P90_MS
            result = "PASS" if ok else "FAIL"
        else:
            result = "PASS" if ratio <= SIM_OVER16_RATIO else "WARN"
        rows.append({"action": action, **data, "ratio": round(ratio, 3), "result": result})
    return rows


def judge_first_screen(samples: list[int], on_device: bool) -> dict:
    budget = DEVICE_FIRST_SCREEN_MS if on_device else SIM_FIRST_SCREEN_MS
    expected = f"中位数 ≤ {budget} ms"
    if not samples:
        return row("首屏", expected, "无输出", "FAIL" if on_device else "WARN")
    median = int(statistics.median(samples))
    actual = f"{median} ms（{' / '.join(str(s) for s in samples)}）"
    if median <= budget:
        result = "PASS"
    else:
        result = "FAIL" if on_device else "WARN"
    return row("首屏", expected, actual, result)


# ---------------------------------------------------------------- stages


def drive_cmd(args, target: str, device: str, extra_defines: list[str], profile: bool) -> list[str]:
    cmd = [
        "flutter",
        "drive",
        "--driver",
        args.driver,
        "--target",
        target,
        "-d",
        device,
    ]
    if profile:
        cmd.append("--profile")
    if args.flavor:
        cmd += ["--flavor", args.flavor]
    if args.dart_define_file:
        cmd += ["--dart-define-from-file", args.dart_define_file]
    for define in extra_defines:
        cmd += ["--dart-define", define]
    return cmd


def stage_l1(args, app_dir: Path, logs: Path) -> dict:
    code, output, _ = run(["flutter", "analyze"], app_dir, logs / "l1-analyze.log", timeout=args.timeout)
    issues = re.search(r"(\d+) issues? found", output)
    analyze = {
        "ok": code == 0,
        "summary": "No issues found" if code == 0 else (issues[0] if issues else f"exit {code}"),
    }
    code, output, seconds = run(
        ["flutter", "test", "--reporter", "json"],
        app_dir,
        logs / "l1-test.jsonl",
        timeout=args.timeout,
    )
    tests = parse_flutter_test(output)
    tests["ok"] = code == 0 and tests["all_passed"]
    tests["seconds"] = round(seconds)
    log(f"flutter test: 通过 {tests['passed']}，失败 {tests['failed']}，跳过 {tests['skipped']}")
    for name in tests["failed_names"]:
        log(f"  FAIL {name}")

    categories = []
    for keyword, meaning in L1_CATEGORIES:
        names = [n for n in tests["names"] if keyword in n]
        failures = [n for n in tests["failed_names"] if keyword in n]
        if not names:
            result, note = "FAIL", "未找到用例：按 assets/quality_test.example.dart 补齐"
        else:
            result = "FAIL" if failures else "PASS"
            note = f"{len(names)} 个用例，失败 {len(failures)}"
            if failures:
                note += "：" + "；".join(failures[:3])
        categories.append({"item": keyword, "meaning": meaning, "result": result, "note": note})
    return {"analyze": analyze, "tests": tests, "categories": categories}


def stage_main_loop(args, app_dir: Path, logs: Path, shots: Path, device: str, profile: bool, rounds: int) -> list[dict]:
    results = []
    tag = "l3" if profile else "l2"
    for round_index in range(1, rounds + 1):
        for target in args.main_loop:
            name = Path(target).stem
            code, output, seconds = run(
                drive_cmd(args, target, device, [], profile),
                app_dir,
                logs / f"{tag}-main-{name}-r{round_index}.log",
                env={"SCREENSHOT_DIR": str(shots)},
                timeout=args.timeout,
            )
            metrics = parse_metrics(output)
            results.append(
                {
                    "round": round_index,
                    "target": target,
                    "ok": code == 0,
                    "first_screen_ms": metrics["first_screen_ms"],
                    "seconds": round(seconds),
                    "metrics": metrics,
                }
            )
    return results


def stage_qa_simulator(args, app_dir: Path, logs: Path, udid: str, bundle: str | None) -> list[dict]:
    results = []
    for permission in ("granted", "denied"):
        if bundle:
            set_photos(udid, bundle, args.photos_service, grant=permission == "granted")
            grant_notifications(udid, bundle)
        code, output, seconds = run(
            drive_cmd(args, args.qa_target, udid, [f"QA_ALBUM={permission}"], profile=False),
            app_dir,
            logs / f"l2-qa-{permission}.log",
            timeout=args.timeout,
        )
        metrics = parse_metrics(output)
        results.append(
            {
                "album_permission": permission,
                "ok": code == 0,
                "seconds": round(seconds),
                "metrics": metrics,
            }
        )
        if "album" in metrics["skips"]:
            break
    if bundle:
        set_photos(udid, bundle, args.photos_service, grant=True)
    return results


# ---------------------------------------------------------------- report


def md_table(rows: list[list[str]], empty: str, columns: int) -> str:
    if not rows:
        return "| " + " | ".join([empty] + ["-"] * (columns - 1)) + " |"
    return "\n".join("| " + " | ".join(str(c) for c in r) + " |" for r in rows)


def collect_blockers(results: dict) -> list[list[str]]:
    blockers = []

    def add(layer: str, text: str, evidence: str) -> None:
        blockers.append([str(len(blockers) + 1), layer, text, "open", evidence])

    l1 = results.get("l1")
    if l1:
        if not l1["analyze"]["ok"]:
            add("L1", f"flutter analyze：{l1['analyze']['summary']}", "logs/l1-analyze.log")
        if not l1["tests"]["ok"]:
            add("L1", f"flutter test 失败 {l1['tests']['failed']} 个", "logs/l1-test.jsonl")
        for category in l1["categories"]:
            if category["result"] == "FAIL":
                add("L1", f"{category['item']}：{category['note']}", "logs/l1-test.jsonl")

    l2 = results["l2"]
    for drive in l2["main_loop"]:
        if not drive["ok"]:
            add("L2", f"主路径 {drive['target']} 第 {drive['round']} 轮失败", "logs/")
    if not l2["main_loop"]:
        add("L2", "未找到主路径测试（integration_test/*_test.dart）", "-")
    for drive in l2["qa"]:
        if not drive["ok"]:
            add("L2", f"QA 探针（相册 {drive['album_permission']}）失败", f"logs/l2-qa-{drive['album_permission']}.log")
    if not l2["qa"]:
        add("L2", f"未找到 QA 探针 {l2['qa_target']}", "assets/qa_simulator_test.example.dart")
    for r in l2["system_rows"]:
        if r["result"] == "FAIL":
            add("L2", f"{r['item']}：期望 {r['expected']}，实测 {r['actual']}", "autotest-results.json")

    l3 = results["l3"]
    for r in l3.get("rows", []):
        if r["result"] == "FAIL":
            add("L3", f"{r['item']}：期望 {r['expected']}，实测 {r['actual']}", "autotest-results.json")
    for drive in l3.get("drives", []):
        if not drive["ok"]:
            add("L3", f"真机 {drive['target']} 失败", "logs/")
    return blockers


def render_report(results: dict, report_path: Path, output_dir: Path) -> str:
    def rel(path: Path) -> str:
        return os.path.relpath(path, report_path.parent)

    l1 = results.get("l1")
    if l1:
        l1_rows = [
            ["flutter analyze", "PASS" if l1["analyze"]["ok"] else "FAIL", l1["analyze"]["summary"]],
            [
                "flutter test",
                "PASS" if l1["tests"]["ok"] else "FAIL",
                f"通过 {l1['tests']['passed']}，失败 {l1['tests']['failed']}，跳过 {l1['tests']['skipped']}，{l1['tests']['seconds']}s",
            ],
        ]
        l1_rows += [[f"{c['item']}（{c['meaning']}）", c["result"], c["note"]] for c in l1["categories"]]
    else:
        l1_rows = [["L1", "FAIL", "本次运行使用了 --skip-l1，需重跑"]]

    l2 = results["l2"]
    main_rows = [
        [
            f"{d['round']} · {Path(d['target']).name}",
            "PASS" if d["ok"] else "FAIL",
            d["first_screen_ms"] if d["first_screen_ms"] is not None else "-",
            d["seconds"],
        ]
        for d in l2["main_loop"]
    ]
    system_rows = [[r["item"], r["expected"], r["actual"], r["result"]] for r in l2["system_rows"]]
    perf_rows = [
        [
            p["action"],
            p.get("frames", 0),
            p.get("build_p50", "-"),
            p.get("build_p90", "-"),
            p.get("build_max", "-"),
            p.get("raster_p90", "-"),
            f"{p['over16']} ({p['ratio']:.0%})" if "over16" in p else "-",
            p["result"],
        ]
        for p in l2["perf_rows"]
    ]
    shots_dir = output_dir / "screens"
    shots = sorted(shots_dir.glob("*.png")) if shots_dir.is_dir() else []
    screenshots = "、".join(f"[{s.stem}]({rel(s)})" for s in shots) or "无"

    l3 = results["l3"]
    l3_rows = [[r["item"], r["expected"], r["actual"], r["result"]] for r in l3.get("rows", [])]
    l3_rows += [
        [f"帧耗时 · {p['action']}", f"≤{DEVICE_OVER16_RATIO:.0%} 超 16ms，build p90 ≤ {DEVICE_BUILD_P90_MS} ms",
         f"{p.get('over16', '-')} / {p.get('frames', 0)}，p90 {p.get('build_p90', '-')} ms", p["result"]]
        for p in l3.get("perf_rows", [])
    ]

    blockers = collect_blockers(results)
    values = {
        "app_name": results["app_name"],
        "slug": results["slug"],
        "date": results["generated_at"][:10],
        "commit": results["commit"],
        "simulator": results["targets"]["simulator"] or "-",
        "device": results["targets"]["device"] or "-",
        "results_json": f"[autotest-results.json]({rel(output_dir / 'autotest-results.json')})",
        "l1_rows": md_table(l1_rows, "无", 3),
        "main_loop_rows": md_table(main_rows, "未运行", 4),
        "system_rows": md_table(system_rows, "未运行", 4),
        "perf_rows": md_table(perf_rows, "无数据", 8),
        "screenshots": screenshots,
        "l3_status": l3["status"],
        "l3_confirmed_by": l3.get("confirmed_by") or "-",
        "l3_rows": md_table(l3_rows, "未运行", 4),
        "blocker_rows": md_table(blockers, "-", 5) if blockers else "| - | - | 无 | - | - |",
        "gate": results["gate"],
        "gate_note": results["gate_note"],
    }
    text = TEMPLATE.read_text(encoding="utf-8")
    for key, value in values.items():
        text = text.replace("{{" + key + "}}", str(value))
    return text


# ---------------------------------------------------------------- main


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("app_dir", help="Flutter app directory (contains pubspec.yaml)")
    parser.add_argument("--slug", required=True, help="product_slug used for docs/workflow/<slug>")
    parser.add_argument("--simulator", help="booted simulator UDID (default: first booted iPhone)")
    parser.add_argument("--device", help="physical iPhone id for L3 (flutter drive --profile)")
    parser.add_argument("--l3-deferred-by", help="who confirmed deferring L3 when no device is available")
    parser.add_argument("--bundle-id", help="iOS bundle id (default: read from Runner.xcodeproj)")
    parser.add_argument("--flavor", help="flutter --flavor, e.g. dev")
    parser.add_argument("--dart-define-file", help="--dart-define-from-file, e.g. dart_defines.dev.json")
    parser.add_argument("--driver", default="test_driver/integration_test.dart")
    parser.add_argument(
        "--main-loop",
        action="append",
        help="main-loop integration target (repeatable; default: integration_test/*_test.dart except --qa-target)",
    )
    parser.add_argument("--qa-target", default="integration_test/qa_simulator_test.dart")
    parser.add_argument("--photos-service", default="photos-add", help="simctl privacy service for album writes")
    parser.add_argument("--rounds", type=int, default=3, help="main-loop rounds on the simulator")
    parser.add_argument("--skip-l1", action="store_true", help="skip analyze/test (report marks L1 as not run)")
    parser.add_argument("--timeout", type=int, default=1800, help="seconds per flutter command")
    parser.add_argument("--app-name", help="report title (default: pubspec name)")
    parser.add_argument("--workflow-dir", help="report dir (default: <project>/docs/workflow/<slug>)")
    parser.add_argument("--output-dir", help="results dir (default: <project>/output/qa/<slug>)")
    args = parser.parse_args()

    app_dir = Path(args.app_dir).resolve()
    if not (app_dir / "pubspec.yaml").exists():
        print(f"ERROR: {app_dir} has no pubspec.yaml", file=sys.stderr)
        return 2
    if not shutil.which("flutter"):
        print("ERROR: flutter not found in PATH", file=sys.stderr)
        return 2

    root = find_project_root(app_dir)
    workflow_dir = Path(args.workflow_dir).resolve() if args.workflow_dir else root / "docs" / "workflow" / args.slug
    output_dir = Path(args.output_dir).resolve() if args.output_dir else root / "output" / "qa" / args.slug
    logs = output_dir / "logs"
    shots = output_dir / "screens"
    logs.mkdir(parents=True, exist_ok=True)

    simulator = args.simulator or detect_simulator()
    if not simulator:
        print("ERROR: no booted iPhone simulator; boot one or pass --simulator", file=sys.stderr)
        return 2
    quiet(["xcrun", "simctl", "bootstatus", simulator, "-b"], timeout=300)
    bundle = args.bundle_id or detect_bundle_id(app_dir)
    if not bundle:
        log("未能唯一确定 bundle id：跳过权限预置（传 --bundle-id 修正）")

    driver = app_dir / args.driver
    if not driver.exists():
        driver.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(DRIVER_ASSET, driver)
        log(f"已安装截图 driver：{driver.relative_to(app_dir)}")
    if not args.main_loop:
        args.main_loop = sorted(
            str(p.relative_to(app_dir))
            for p in (app_dir / "integration_test").glob("*_test.dart")
            if str(p.relative_to(app_dir)) != args.qa_target
        )
    has_qa = (app_dir / args.qa_target).exists()

    results: dict = {
        "slug": args.slug,
        "app_name": args.app_name or pubspec_name(app_dir),
        "generated_at": dt.datetime.now().isoformat(timespec="seconds"),
        "app_dir": str(app_dir),
        "commit": git_commit(app_dir),
        "targets": {"simulator": simulator, "device": args.device, "bundle_id": bundle},
        "options": {
            "flavor": args.flavor,
            "dart_define_file": args.dart_define_file,
            "rounds": args.rounds,
            "main_loop": args.main_loop,
            "qa_target": args.qa_target,
        },
    }

    log("== L1 组件质量 ==")
    results["l1"] = None if args.skip_l1 else stage_l1(args, app_dir, logs)

    log("== L2 模拟器 ==")
    main_loop = stage_main_loop(args, app_dir, logs, shots, simulator, profile=False, rounds=args.rounds)
    qa_runs = stage_qa_simulator(args, app_dir, logs, simulator, bundle) if has_qa else []
    system_rows = []
    first_screens = [d["first_screen_ms"] for d in main_loop if d["first_screen_ms"] is not None]
    first_screens += [q["metrics"]["first_screen_ms"] for q in qa_runs if q["metrics"]["first_screen_ms"] is not None]
    system_rows.append(judge_first_screen(first_screens, on_device=False))
    perf: dict = {}
    for index, qa in enumerate(qa_runs):
        rows = judge_system(qa["metrics"], qa["album_permission"], on_device=False)
        if index == 0:
            system_rows += rows
            perf = qa["metrics"]["perf"]
        else:
            album_at = max(i for i, r in enumerate(system_rows) if r["item"].startswith("相册")) + 1
            system_rows[album_at:album_at] = [r for r in rows if r["item"].startswith("相册")]
    results["l2"] = {
        "main_loop": main_loop,
        "qa": qa_runs,
        "qa_target": args.qa_target,
        "system_rows": system_rows,
        "perf_rows": judge_perf(perf, on_device=False),
    }

    log("== L3 真机 ==")
    if args.device:
        drives = stage_main_loop(args, app_dir, logs, shots / "device", args.device, profile=True, rounds=1)
        rows: list[dict] = []
        device_perf: dict = {}
        if has_qa:
            code, output, seconds = run(
                drive_cmd(args, args.qa_target, args.device, ["QA_ALBUM=granted"], profile=True),
                app_dir,
                logs / "l3-qa.log",
                timeout=args.timeout,
            )
            metrics = parse_metrics(output)
            drives.append({"target": args.qa_target, "ok": code == 0, "seconds": round(seconds), "metrics": metrics})
            rows += judge_system(metrics, "granted", on_device=True)
            device_perf = metrics["perf"]
        firsts = [d["metrics"]["first_screen_ms"] for d in drives if d["metrics"]["first_screen_ms"] is not None]
        rows.insert(0, judge_first_screen(firsts, on_device=True))
        results["l3"] = {
            "status": "done",
            "drives": drives,
            "rows": rows,
            "perf_rows": judge_perf(device_perf, on_device=True),
        }
    elif args.l3_deferred_by:
        results["l3"] = {"status": "deferred", "confirmed_by": args.l3_deferred_by}
        log(f"L3 deferred，确认人：{args.l3_deferred_by}")
    else:
        results["l3"] = {"status": "pending"}
        log("未提供 --device 或 --l3-deferred-by：L3 待定")

    blockers = collect_blockers(results)
    notes = []
    if blockers:
        notes.append(f"{len(blockers)} 个阻塞项待修复")
    if results["l1"] is None:
        notes.append("L1 未运行")
    if results["l3"]["status"] == "pending":
        notes.append("L3 待定：接真机加 --device，或经用户确认后加 --l3-deferred-by")
    passed = not notes
    if passed and results["l3"]["status"] == "done":
        notes.append("自动项全部通过；勾选真机手动清单后再运行 validate_autotest_report.py")
    if passed and results["l3"]["status"] == "deferred":
        notes.append(f"L1/L2 全部通过；L3 已延期（{results['l3']['confirmed_by']} 确认）")
    warns = [r["action"] for r in results["l2"]["perf_rows"] if r["result"] == "WARN"]
    warns += [r["item"] for r in system_rows if r["result"] == "WARN"]
    if warns:
        notes.append("模拟器 debug 超参考值（WARN，需真机复核）：" + "、".join(warns))
    results["gate"] = "PASS" if passed else "FAIL"
    results["gate_note"] = "；".join(notes)

    results_path = output_dir / "autotest-results.json"
    results_path.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    workflow_dir.mkdir(parents=True, exist_ok=True)
    report_path = workflow_dir / "autotest-report.md"
    report_path.write_text(render_report(results, report_path, output_dir), encoding="utf-8")

    log(f"results: {results_path}")
    log(f"report:  {report_path}")
    log(f"autotest_gate: {results['gate']} — {results['gate_note']}")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
