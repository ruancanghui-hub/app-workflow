#!/usr/bin/env python3
"""Feature-level regression check for a Flutter app.

Steps: changed Dart files (vs --base, plus untracked) -> dart format on those
files only, skipping files that were not format-clean at --base (formatting
them would bury the real edits in unrelated churn) -> flutter analyze (issues
in changed files block, others are pre-existing) -> optional targeted tests ->
full flutter test.

Prints a JSON summary; the last line is PASS or FAIL (exit code 0 / 1).
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

GENERATED_SUFFIXES = (".g.dart", ".freezed.dart", ".gr.dart", ".mocks.dart")
ANALYZE_LINE = re.compile(
    r"^\s*(error|warning|info)\s+•\s+(.+?)\s+•\s+(\S+?):(\d+):(\d+)\s+•\s+(\S+)\s*$"
)
TEST_PROGRESS = re.compile(r"\+(\d+)(?: ~(\d+))?(?: -(\d+))?:")


def run(cmd: list[str], cwd: Path, quiet: bool = False) -> subprocess.CompletedProcess[str]:
    if not quiet:
        print(f"$ {' '.join(cmd)}", file=sys.stderr, flush=True)
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


def find_app_dir(arg: str | None) -> Path:
    if arg:
        app = Path(arg).expanduser().resolve()
        if not (app / "pubspec.yaml").is_file():
            sys.exit(f"ERROR: no pubspec.yaml in {app}")
        return app
    here = Path.cwd().resolve()
    for candidate in (here, *here.parents):
        if (candidate / "pubspec.yaml").is_file():
            return candidate
    sys.exit("ERROR: no pubspec.yaml found; pass --app-dir")


def changed_dart_files(app: Path, base: str) -> list[str]:
    top = run(["git", "rev-parse", "--show-toplevel"], app)
    if top.returncode != 0:
        sys.exit(f"ERROR: {app} is not inside a git repository")
    repo = Path(top.stdout.strip())

    diff = run(["git", "diff", "--name-only", base, "--", "."], app)
    if diff.returncode != 0:
        sys.exit(f"ERROR: git diff failed for base '{base}':\n{diff.stderr}")
    untracked = run(["git", "ls-files", "--others", "--exclude-standard", "--", "."], app)

    paths = {repo / p for p in diff.stdout.splitlines() if p}
    paths |= {app / p for p in untracked.stdout.splitlines() if p}

    files = []
    for path in paths:
        if path.suffix != ".dart" or path.name.endswith(GENERATED_SUFFIXES):
            continue
        if not path.is_file():
            continue
        try:
            files.append(str(path.resolve().relative_to(app)))
        except ValueError:
            continue
    return sorted(files)


def unformatted_at_base(app: Path, files: list[str], base: str) -> set[str]:
    """Changed files whose --base version was already not dart-format clean."""
    scratch = app / ".dart_tool" / "feature_check" / "base"
    shutil.rmtree(scratch, ignore_errors=True)
    copied = []
    for rel in files:
        show = run(["git", "show", f"{base}:./{rel}"], app, quiet=True)
        if show.returncode != 0:
            continue
        target = scratch / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(show.stdout)
        copied.append(rel)
    if not copied:
        return set()
    scratch_rel = scratch.relative_to(app)
    proc = run(["dart", "format", "--output=none", str(scratch_rel)], app, quiet=True)
    prefix = f"Changed {scratch_rel}/"
    legacy = {
        line[len(prefix):].strip()
        for line in proc.stdout.splitlines()
        if line.startswith(prefix)
    }
    shutil.rmtree(scratch, ignore_errors=True)
    return legacy


def format_changed(app: Path, files: list[str], base: str) -> dict:
    legacy = unformatted_at_base(app, files, base)
    targets = [f for f in files if f not in legacy]
    result: dict = {"ok": True, "formatted": [], "skipped_unformatted_at_base": sorted(legacy)}
    if targets:
        proc = run(["dart", "format", *targets], app)
        result["ok"] = proc.returncode == 0
        result["formatted"] = [
            line.split(" ", 1)[1].strip()
            for line in proc.stdout.splitlines()
            if re.match(r"^(Formatted|Changed) (?!\d+ files?)", line)
        ]
        if not result["ok"]:
            print(tail(proc.stdout + proc.stderr), file=sys.stderr)
    return result


def tail(text: str, lines: int = 60) -> str:
    return "\n".join(text.splitlines()[-lines:])


def analyze(app: Path, changed: set[str]) -> dict:
    proc = run(["flutter", "analyze", "--no-pub"], app)
    output = proc.stdout + proc.stderr
    blocking, changed_infos, existing = [], [], []
    for line in output.splitlines():
        match = ANALYZE_LINE.match(line)
        if not match:
            continue
        severity, message, path, row, col, code = match.groups()
        issue = f"{severity} {path}:{row}:{col} {code} - {message}"
        if path in changed:
            (blocking if severity in ("error", "warning") else changed_infos).append(issue)
        else:
            existing.append(issue)

    parsed = blocking or changed_infos or existing or "No issues found" in output
    ran_ok = proc.returncode == 0 or parsed
    if not ran_ok:
        print(tail(output), file=sys.stderr)
    return {
        "ok": ran_ok and not blocking,
        "blocking": blocking,
        "changed_file_infos": changed_infos,
        "pre_existing_count": len(existing),
        "pre_existing": existing[:20],
    }


def flutter_test(app: Path, targets: list[str]) -> dict:
    proc = run(["flutter", "test", "--no-pub", *targets], app)
    output = proc.stdout + proc.stderr
    progress = TEST_PROGRESS.findall(output)
    passed, skipped, failed = (int(v or 0) for v in progress[-1]) if progress else (0, 0, 0)
    failing = sorted(
        {line.strip() for line in output.splitlines() if line.rstrip().endswith("[E]")}
    )
    if proc.returncode != 0:
        print(tail(output, 120), file=sys.stderr)
    return {
        "ok": proc.returncode == 0,
        "targets": targets or ["<all>"],
        "passed": passed,
        "skipped": skipped,
        "failed": failed,
        "failing": failing[:20],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--app-dir", help="Flutter project directory (default: nearest pubspec.yaml)")
    parser.add_argument("--base", default="HEAD", help="git base to diff against (default: HEAD)")
    parser.add_argument("--tests", nargs="*", default=[], help="feature test files to run first")
    parser.add_argument("--skip-full", action="store_true", help="skip the full flutter test run")
    parser.add_argument("--no-format", action="store_true", help="do not run dart format")
    args = parser.parse_args()

    app = find_app_dir(args.app_dir)
    changed = changed_dart_files(app, args.base)
    summary: dict = {"app_dir": str(app), "base": args.base, "changed_dart_files": changed}

    if changed and not args.no_format:
        summary["format"] = format_changed(app, changed, args.base)
    else:
        summary["format"] = {"ok": True, "skipped": True}

    summary["analyze"] = analyze(app, set(changed))

    steps_ok = summary["format"]["ok"] and summary["analyze"]["ok"]
    if args.tests:
        summary["feature_tests"] = flutter_test(app, args.tests)
        steps_ok = steps_ok and summary["feature_tests"]["ok"]
    if args.skip_full:
        summary["full_tests"] = {"ok": True, "skipped": True}
    elif not args.tests or summary["feature_tests"]["ok"]:
        summary["full_tests"] = flutter_test(app, [])
        steps_ok = steps_ok and summary["full_tests"]["ok"]

    verdict = "PASS" if steps_ok else "FAIL"
    summary["verdict"] = verdict
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    print(verdict)
    return 0 if steps_ok else 1


if __name__ == "__main__":
    sys.exit(main())
