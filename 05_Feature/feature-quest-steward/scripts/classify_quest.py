#!/usr/bin/env python3
"""Classify a quest track (main / side / needs_triage)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _steward_lib import classify  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description="Quest Steward classifier")
    p.add_argument("--title", default="")
    p.add_argument("--summary", default="")
    p.add_argument("--fxx", default="", help="Comma-separated F01,F02")
    p.add_argument("--priority", default="unknown")
    p.add_argument("--mvp-loop", action="store_true")
    p.add_argument("--infra", action="store_true")
    p.add_argument("--deferred-tab", action="store_true")
    p.add_argument("--track-override", choices=["main", "side", "needs_triage"])
    p.add_argument("--override-reason", default=None)
    args = p.parse_args()

    fxx = [x for x in args.fxx.split(",") if x.strip()]
    try:
        result = classify(
            title=args.title,
            summary=args.summary,
            fxx=fxx,
            priority=args.priority,
            mvp_loop=args.mvp_loop,
            infra=args.infra,
            deferred_tab=args.deferred_tab,
            track_override=args.track_override,
            override_reason=args.override_reason,
        )
    except ValueError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 2

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
