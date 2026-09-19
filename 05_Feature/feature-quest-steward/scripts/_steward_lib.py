#!/usr/bin/env python3
"""Shared helpers for feature-quest-steward scripts."""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ASSETS = Path(__file__).resolve().parents[1] / "assets"

LOOP_KW = (
    "打开",
    "拦截",
    "微干预",
    "呼吸",
    "意图",
    "继续",
    "放弃",
    "统计",
    "今日",
    "intervene",
    "breathe",
    "intent",
    "abandon",
    "guarded",
)
INFRA_KW = (
    "系统拦截",
    "screen time",
    "shortcuts",
    "storekit",
    "play billing",
    "恢复购买",
    "权限真机",
    "healthkit",
    "真拦截",
    "真订阅",
)
SIDE_KW = (
    "动效",
    "高级交互",
    "生理触发",
    "网站拦截",
    "习惯提醒",
    "再次干预",
    "polish",
    "animation only",
)


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def slugify(text: str, max_len: int = 32) -> str:
    s = text.strip().lower()
    s = re.sub(r"[^\w\s-]", "", s, flags=re.UNICODE)
    s = re.sub(r"[\s_]+", "-", s).strip("-")
    if not s:
        s = "quest"
    return s[:max_len]


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def dump_json(path: Path, data: Any) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def quests_dir(workflow_slug_dir: Path) -> Path:
    return workflow_slug_dir / "quests"


def classify(
    *,
    title: str = "",
    summary: str = "",
    fxx: list[str] | None = None,
    priority: str = "unknown",
    mvp_loop: bool = False,
    infra: bool = False,
    deferred_tab: bool = False,
    track_override: str | None = None,
    override_reason: str | None = None,
) -> dict[str, Any]:
    fxx = [x.strip().upper() for x in (fxx or []) if x.strip()]
    blob = f"{title} {summary}".lower()
    auto_infra = infra or any(k in blob for k in INFRA_KW)
    auto_loop = mvp_loop or any(k in blob for k in LOOP_KW)
    side_kw = any(k in blob for k in SIDE_KW)
    pri = (priority or "unknown").upper()
    if pri not in ("P0", "P1", "P2", "UNKNOWN"):
        pri = "UNKNOWN"

    auto_track: str
    kind = "feature"
    # Waterfall aligned with classification-rules.md (override applied after)
    if auto_infra and pri in ("P0", "UNKNOWN"):
        auto_track = "main"
        kind = "infra"
        reason = "P0 infra (system intercept / billing / real permissions)"
    elif fxx and (auto_loop or pri == "P0"):
        auto_track = "main"
        reason = f"bound {','.join(fxx)} on MVP loop or P0"
    elif auto_loop and pri == "P0":
        auto_track = "main"
        reason = "MVP loop + P0"
    elif pri == "P0" and fxx:
        auto_track = "main"
        reason = f"P0 with Fxx {','.join(fxx)}"
    elif pri in ("P1", "P2") or deferred_tab or (side_kw and pri != "P0" and not auto_loop and not auto_infra):
        auto_track = "side"
        reason = f"priority={pri}" if pri in ("P1", "P2") else "side/deferred signals"
    elif not fxx and not auto_infra and pri == "UNKNOWN" and not auto_loop:
        auto_track = "needs_triage"
        reason = "cannot map Fxx / loop / infra — needs triage"
    elif auto_loop:
        auto_track = "main"
        reason = "MVP loop keywords"
    else:
        auto_track = "needs_triage"
        reason = "ambiguous inputs — needs triage"

    track = auto_track
    if track_override in ("main", "side"):
        if track_override != auto_track and not override_reason:
            raise ValueError("override_reason required when track_override differs from auto track")
        track = track_override
        reason = f"human override → {track} (auto was {auto_track}): {override_reason or 'n/a'}"
    elif track_override == "needs_triage":
        track = "needs_triage"
        reason = f"human forced triage: {override_reason or 'n/a'}"

    status = "needs_triage" if track == "needs_triage" else "queued"
    return {
        "track": track,
        "kind": kind if track == "main" else "feature",
        "status": status,
        "reason": reason,
        "fxx": fxx,
        "priority": pri.lower() if pri == "UNKNOWN" else pri,
        "mvp_loop": bool(auto_loop or mvp_loop),
        "infra": bool(auto_infra),
    }


def next_quest_id(backlog: dict[str, Any], title: str) -> str:
    nums = []
    for q in backlog.get("quests") or []:
        m = re.match(r"q-(\d+)", q.get("id", ""))
        if m:
            nums.append(int(m.group(1)))
    n = (max(nums) + 1) if nums else 1
    return f"q-{n:03d}-{slugify(title)}"


def render_backlog_md(backlog: dict[str, Any]) -> str:
    slug = backlog.get("product_slug") or "<slug>"
    lines = [
        f"# Quests Backlog — {slug}",
        "",
        "> 真源：`backlog.json`。本文件由管家脚本同步，勿手改状态列。",
        "",
        "| ID | Track | Kind | Status | Fxx | Title |",
        "|----|-------|------|--------|-----|-------|",
    ]
    quests = backlog.get("quests") or []
    if not quests:
        lines.append("| — | — | — | — | — | （空队列） |")
    else:
        for q in quests:
            fxx = ",".join(q.get("fxx") or []) or "—"
            lines.append(
                f"| {q.get('id','')} | {q.get('track','')} | {q.get('kind','feature')} | "
                f"{q.get('status','')} | {fxx} | {q.get('title','')} |"
            )
    lines += [
        "",
        "## Rules",
        "",
        "- Main 清空前默认不开 Side",
        "- `needs_triage` 须人工补齐后再入队",
        "",
    ]
    return "\n".join(lines)


def sync_backlog_md(quests_path: Path, backlog: dict[str, Any]) -> None:
    (quests_path / "BACKLOG.md").write_text(render_backlog_md(backlog), encoding="utf-8")


def append_steward_log(quests_path: Path, entry: str) -> None:
    log_path = quests_path / "steward-log.md"
    if not log_path.exists():
        log_path.write_text(
            f"# Steward log\n\n---\n\n## {utc_now()}\n\n{entry}\n",
            encoding="utf-8",
        )
        return
    old = log_path.read_text(encoding="utf-8")
    block = f"## {utc_now()}\n\n{entry}\n\n---\n\n"
    # insert after title block
    if "<!-- entries below -->" in old:
        old = old.replace("<!-- entries below -->", "<!-- entries below -->\n\n" + block, 1)
        log_path.write_text(old, encoding="utf-8")
    else:
        log_path.write_text(block + old, encoding="utf-8")


def copy_template(name: str, dest: Path, replacements: dict[str, str]) -> None:
    src = ASSETS / name
    text = src.read_text(encoding="utf-8")
    for k, v in replacements.items():
        text = text.replace(k, v)
    dest.write_text(text, encoding="utf-8")


def scaffold_quest_dir(quests_path: Path, quest: dict[str, Any]) -> Path:
    qdir = quests_path / quest["id"]
    qdir.mkdir(parents=True, exist_ok=True)
    title = quest.get("title") or quest["id"]
    dump_json(qdir / "quest.json", quest)
    reps = {"<title>": title, "<slug>": quest.get("product_slug") or ""}
    for name, out in (
        ("01-quest-doc.template.md", "01-quest-doc.md"),
        ("02-ui-interaction-spec.template.md", "02-ui-interaction-spec.md"),
        ("03-acceptance.template.md", "03-acceptance.md"),
    ):
        if not (qdir / out).exists():
            copy_template(name, qdir / out, reps)
    return qdir


def placeholder_filled(path: Path, min_chars: int = 80) -> bool:
    if not path.is_file():
        return False
    text = path.read_text(encoding="utf-8").strip()
    if len(text) < min_chars:
        return False
    # still mostly template
    bad = ("一句话：用户完成什么", "<title>", "E1 | …")
    hits = sum(1 for b in bad if b in text)
    return hits < 2
