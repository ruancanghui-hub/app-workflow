#!/usr/bin/env python3
"""Validate selected-source preservation and reusable root-tab structure."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
from pathlib import Path


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()[:24]
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a PNG: {path}")
    return struct.unpack(">II", data[16:24])


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(source: Path, core_dir: Path, tabs: list[tuple[str, str]], prototype_html: Path | None) -> list[str]:
    errors: list[str] = []
    if not tabs:
        return ["at least one --tab id=label is required"]
    tab_ids = [tab_id for tab_id, _ in tabs]
    if len(tab_ids) != len(set(tab_ids)):
        return ["tab IDs must be unique"]
    source_copy = core_dir / f"tab-{tab_ids[0]}.png"
    expected = [core_dir / f"tab-{tab_id}.png" for tab_id in tab_ids]
    for path in (source, *expected):
        if not path.is_file():
            errors.append(f"missing file: {path}")
    if errors:
        return errors

    source_size = png_size(source)
    if sha256(source) != sha256(source_copy):
        errors.append(f"{source_copy.name} is not a byte-identical copy of the approved source")
    for path in expected:
        if png_size(path) != source_size:
            errors.append(f"canvas mismatch: {path.name} is {png_size(path)}, expected {source_size}")

    lock = core_dir / "00-style-lock.md"
    qa = core_dir / "qa-report.md"
    for path in (lock, qa):
        if not path.is_file():
            errors.append(f"missing contract file: {path}")
    if lock.is_file():
        text = lock.read_text(encoding="utf-8")
        for _, label in tabs:
            if label not in text:
                errors.append(f"style lock missing root label: {label}")

    if prototype_html:
        if not prototype_html.is_file():
            errors.append(f"missing prototype HTML: {prototype_html}")
        else:
            html = prototype_html.read_text(encoding="utf-8")
            nav_matches = re.findall(r'<nav\b[^>]*data-codex-id=["\']root-tabbar["\'][^>]*>[\s\S]*?</nav>', html)
            if len(nav_matches) != 1:
                errors.append("prototype must contain exactly one shared root-tabbar")
            else:
                nav = nav_matches[0]
                if 'data-tab-contract="shared-active-only"' not in nav and "data-tab-contract='shared-active-only'" not in nav:
                    errors.append("root-tabbar missing shared-active-only contract marker")
                actual_ids = re.findall(r'data-tab=["\']([^"\']+)["\']', nav)
                if actual_ids != tab_ids:
                    errors.append(f"prototype tab IDs/order {actual_ids} do not match {tab_ids}")
                positions = [nav.find(f">{label}<") for _, label in tabs]
                if any(position < 0 for position in positions) or positions != sorted(positions):
                    errors.append("prototype root labels are missing or out of order")
            screen_ids = re.findall(r'data-screen=["\']([^"\']+)["\']', html)
            if screen_ids != tab_ids:
                errors.append(f"prototype root screens/order {screen_ids} do not match {tab_ids}")
            nav_pos = html.find('data-codex-id="root-tabbar"')
            if nav_pos < max((html.find(f'data-screen="{tab_id}"') for tab_id in tab_ids), default=-1):
                errors.append("shared root-tabbar must be outside and after all root screen containers")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--core-dir", type=Path, required=True)
    parser.add_argument("--tab", action="append", required=True, metavar="ID=LABEL")
    parser.add_argument("--prototype-html", type=Path)
    args = parser.parse_args()
    tabs: list[tuple[str, str]] = []
    for raw in args.tab:
        if "=" not in raw:
            parser.error("--tab must use ID=LABEL")
        tab_id, label = raw.split("=", 1)
        if not re.fullmatch(r"[a-z][a-z0-9_-]*", tab_id) or not label.strip():
            parser.error("--tab requires a filesystem-safe lowercase ID and non-empty label")
        tabs.append((tab_id, label.strip()))
    errors = validate(args.source.resolve(), args.core_dir.resolve(), tabs, args.prototype_html.resolve() if args.prototype_html else None)
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
