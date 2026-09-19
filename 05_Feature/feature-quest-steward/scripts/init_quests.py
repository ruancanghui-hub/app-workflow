#!/usr/bin/env python3
"""Initialize docs/workflow/<slug>/quests/."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _steward_lib import (  # noqa: E402
    ASSETS,
    dump_json,
    load_json,
    quests_dir,
    sync_backlog_md,
)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("workflow_slug_dir", type=Path, help="docs/workflow/<slug>")
    args = p.parse_args()
    root = args.workflow_slug_dir.resolve()
    if not root.is_dir():
        print(f"FAIL: not a directory: {root}")
        return 1

    slug = root.name
    qdir = quests_dir(root)
    qdir.mkdir(parents=True, exist_ok=True)

    backlog_path = qdir / "backlog.json"
    if backlog_path.exists():
        backlog = load_json(backlog_path)
    else:
        backlog = load_json(ASSETS / "backlog.template.json")
        backlog["product_slug"] = slug
        dump_json(backlog_path, backlog)

    backlog["product_slug"] = slug
    dump_json(backlog_path, backlog)
    sync_backlog_md(qdir, backlog)

    log = qdir / "steward-log.md"
    if not log.exists():
        text = (ASSETS / "steward-log.template.md").read_text(encoding="utf-8")
        log.write_text(text.replace("<slug>", slug), encoding="utf-8")

    print(f"PASS: initialized {qdir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
