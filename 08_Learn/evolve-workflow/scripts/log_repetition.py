#!/usr/bin/env python3
"""Log a repeated workflow friction; alert when count reaches 3."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
REGISTRY_DEFAULT = REPO_ROOT / "00_Orchestrator/app-workflow/registry/repetition-log.json"
PROMOTE_THRESHOLD = 3


def normalize_key(phase: str, pattern: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "_", pattern.lower()).strip("_")
    return f"{phase}:{slug}"[:120]


def load_registry(path: Path) -> dict:
    if path.is_file():
        return json.loads(path.read_text(encoding="utf-8"))
    template = Path(__file__).resolve().parents[1] / "assets/repetition-log.template.json"
    return json.loads(template.read_text(encoding="utf-8"))


def save_registry(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Log workflow repetition")
    parser.add_argument("--phase", required=True, help="prd|ip|prototype|scaffold|features|qa|app_store")
    parser.add_argument("--pattern", required=True, help="Short description of repeated work")
    parser.add_argument("--context", default="", help="What happened this time")
    parser.add_argument("--product-slug", default="", dest="product_slug")
    parser.add_argument("--registry", type=Path, default=REGISTRY_DEFAULT)
    args = parser.parse_args()

    registry_path = args.registry.resolve()
    data = load_registry(registry_path)
    key = normalize_key(args.phase, args.pattern)
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    entry = None
    for e in data.get("entries", []):
        if e.get("normalized_key") == key:
            entry = e
            break

    if entry is None:
        entry = {
            "id": key,
            "phase": args.phase,
            "pattern": args.pattern,
            "normalized_key": key,
            "count": 0,
            "first_seen": now,
            "last_seen": now,
            "product_slugs": [],
            "contexts": [],
            "status": "observed",
            "playbook_path": None,
        }
        data.setdefault("entries", []).append(entry)

    entry["count"] = int(entry.get("count", 0)) + 1
    entry["last_seen"] = now
    if args.product_slug and args.product_slug not in entry["product_slugs"]:
        entry["product_slugs"].append(args.product_slug)
    if args.context:
        entry["contexts"].append({"at": now, "text": args.context})
        entry["contexts"] = entry["contexts"][-10:]

    save_registry(registry_path, data)

    print(f"pattern_id={entry['id']}")
    print(f"count={entry['count']}")
    if entry["count"] >= PROMOTE_THRESHOLD and entry.get("status") != "promoted":
        print("PROMOTE_REQUIRED")
        print("Run: python3 08_Learn/evolve-workflow/scripts/promote_to_playbook.py --pattern-id", entry["id"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
