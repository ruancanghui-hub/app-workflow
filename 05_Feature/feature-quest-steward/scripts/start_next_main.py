#!/usr/bin/env python3
"""Start the next queued Main Quest (scaffold docs; stop at doc confirm)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _steward_lib import (  # noqa: E402
    append_steward_log,
    dump_json,
    load_json,
    quests_dir,
    scaffold_quest_dir,
    sync_backlog_md,
    utc_now,
)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("workflow_slug_dir", type=Path)
    p.add_argument("--force-side", action="store_true", help="Allow starting Side while Main remains")
    p.add_argument("--quest-id", default=None, help="Start a specific queued id")
    args = p.parse_args()

    root = args.workflow_slug_dir.resolve()
    qdir = quests_dir(root)
    backlog_path = qdir / "backlog.json"
    if not backlog_path.is_file():
        print(f"FAIL: missing {backlog_path}")
        return 1

    backlog = load_json(backlog_path)
    quests = backlog.get("quests") or []

    active = [q for q in quests if q.get("status") in ("doc", "design", "page")]
    if active:
        print(f"FAIL: already active quest {active[0]['id']} status={active[0]['status']}")
        return 1

    mains_queued = [q for q in quests if q.get("track") == "main" and q.get("status") == "queued"]
    sides_queued = [q for q in quests if q.get("track") == "side" and q.get("status") == "queued"]

    chosen = None
    if args.quest_id:
        chosen = next((q for q in quests if q.get("id") == args.quest_id), None)
        if not chosen:
            print(f"FAIL: quest id not found: {args.quest_id}")
            return 1
        if chosen.get("status") != "queued":
            print(f"FAIL: quest not queued: {chosen.get('status')}")
            return 1
        if chosen.get("track") == "side" and mains_queued and not args.force_side:
            print("FAIL: Main queue not empty; pass --force-side to start a Side quest")
            return 1
    else:
        if mains_queued:
            chosen = mains_queued[0]
        elif sides_queued:
            if mains_queued:  # unreachable
                pass
            # only side left — allowed
            chosen = sides_queued[0]
        else:
            triage = [q for q in quests if q.get("status") == "needs_triage"]
            if triage:
                print(f"FAIL: no queued quests; {len(triage)} need triage")
            else:
                print("FAIL: backlog empty")
            return 1

    now = utc_now()
    chosen["status"] = "doc"
    chosen["updated_at"] = now

    quest_full = {
        **chosen,
        "product_slug": root.name,
        "force_side": bool(args.force_side),
        "route": chosen.get("route") or "",
        "waivers": chosen.get("waivers") or [],
        "stages": {
            "doc": "PENDING",
            "design": "PENDING",
            "page": "PENDING",
            "done": "PENDING",
        },
        "classification_reason": chosen.get("classification_reason") or "",
    }
    scaffold_quest_dir(qdir, quest_full)

    # persist backlog entry updates
    for i, q in enumerate(quests):
        if q.get("id") == chosen["id"]:
            quests[i] = chosen
            break
    backlog["quests"] = quests
    dump_json(backlog_path, backlog)
    sync_backlog_md(qdir, backlog)

    append_steward_log(
        qdir,
        f"**start** `{chosen['id']}` track=`{chosen.get('track')}` → status=`doc`\n\n"
        f"Stop at Doc confirm gate. Fill `01-quest-doc.md` then run validate_quest_stage.py … doc.",
    )

    print(f"PASS: started {chosen['id']} → docs/workflow/{root.name}/quests/{chosen['id']}/")
    print("NEXT: confirm/fill 01-quest-doc.md then validate stage doc")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
