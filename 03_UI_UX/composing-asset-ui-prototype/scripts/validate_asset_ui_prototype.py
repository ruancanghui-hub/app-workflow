#!/usr/bin/env python3
"""Validate 06_asset_ui package for composing-asset-ui-prototype gate."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REQUIRED_FILES = ("index.html", "styles.css", "app.js", "apply-layout.js", "layout-spec.json", "README.md")
REQUIRED_TABS = ("home", "sleep", "meditation", "sound")
INNER_HTML = re.compile(r"\binnerHTML\b")
CODEX_ROOT = re.compile(r"data-codex-root")
CODEX_ID = re.compile(r'data-codex-id=["\']([^"\']+)["\']')
DATA_SCREEN = re.compile(r'data-screen=["\']([^"\']+)["\']')


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def resolve_slug_root(arg: str) -> Path:
    path = Path(arg).resolve()
    if (path / "06_asset_ui").is_dir():
        return path
    if path.name == "06_asset_ui" and path.is_dir():
        return path.parent
    fail(f"cannot find 06_asset_ui under {path}")


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: validate_asset_ui_prototype.py <brand-ip-slug-dir>")

    slug_root = resolve_slug_root(sys.argv[1])
    ui_dir = slug_root / "06_asset_ui"
    assets_root = slug_root / "05-ui-assets"

    for name in REQUIRED_FILES:
        if not (ui_dir / name).is_file():
            fail(f"missing 06_asset_ui/{name}")

    html = (ui_dir / "index.html").read_text(encoding="utf-8")
    js = (ui_dir / "app.js").read_text(encoding="utf-8")

    if html.count("data-codex-root") != 1:
        fail("index.html must have exactly one data-codex-root")
    if INNER_HTML.search(js):
        fail("app.js must not use innerHTML")

    ids = CODEX_ID.findall(html)
    if len(ids) != len(set(ids)):
        fail("duplicate data-codex-id in index.html")

    screens = set(DATA_SCREEN.findall(html))
    missing_tabs = [t for t in REQUIRED_TABS if t not in screens]
    if missing_tabs:
        fail(f"missing data-screen tabs: {', '.join(missing_tabs)}")

    layout = json.loads((ui_dir / "layout-spec.json").read_text(encoding="utf-8"))
    if "canvas" not in layout or "pages" not in layout:
        fail("layout-spec.json must include canvas and pages")

    for tab in REQUIRED_TABS:
        if tab not in layout.get("pages", {}):
            fail(f"layout-spec.json missing page entry for {tab}")

    broken: list[str] = []
    for match in re.finditer(r'src=["\'](\.\./05-ui-assets/[^"\']+)["\']', html):
        rel = match.group(1)
        if not (slug_root / rel.removeprefix("../")).exists():
            broken.append(rel)
    if broken:
        fail(f"broken asset paths: {', '.join(broken[:5])}" + (" ..." if len(broken) > 5 else ""))

    if not assets_root.is_dir():
        fail(f"missing 05-ui-assets at {assets_root}")

    for tab in REQUIRED_TABS:
        manifest = assets_root / tab / "manifest.json"
        if not manifest.is_file():
            fail(f"missing 05-ui-assets/{tab}/manifest.json")

    print(f"OK: asset UI prototype valid at {ui_dir}")


if __name__ == "__main__":
    main()
