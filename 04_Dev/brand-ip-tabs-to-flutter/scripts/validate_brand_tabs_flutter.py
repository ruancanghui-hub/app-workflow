#!/usr/bin/env python3
"""Validate brand-ip-tabs-to-flutter delivery against handoff."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def _fail(msg: str) -> None:
    print(f"FAIL: {msg}")


def _resolve(manifest_path: Path, rel: str) -> Path:
    p = Path(rel)
    if p.is_absolute():
        return p
    return (manifest_path.parent / rel).resolve()


def _find_root() -> Path | None:
    here = Path(__file__).resolve()
    candidate = here.parents[3]
    if (candidate / "00_Orchestrator" / "app-workflow").is_dir():
        return candidate
    link = Path.home() / ".cursor" / "skills" / "app-workflow-root"
    if link.exists():
        return link.resolve()
    return None


def validate(manifest_path: Path) -> list[str]:
    errors: list[str] = []
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [f"invalid JSON: {exc}"]

    gates = manifest.get("gates") or {}
    for g in ("prd", "ip", "prototype", "flutter_scaffold"):
        if gates.get(g) != "PASS":
            errors.append(f"gates.{g} must be PASS")

    brand = (manifest.get("phases") or {}).get("brand") or {}
    core = brand.get("core_tab_ui_dir") or ""
    if not core:
        errors.append("phases.brand.core_tab_ui_dir empty")
    else:
        core_path = Path(core)
        if not core_path.is_dir():
            errors.append(f"core_tab_ui_dir missing: {core}")

    flutter = (manifest.get("phases") or {}).get("flutter") or {}
    out = flutter.get("output_dir") or ""
    if not out:
        errors.append("phases.flutter.output_dir empty")
    else:
        app_dir = _resolve(manifest_path, out)
        if not app_dir.is_dir():
            errors.append(f"flutter app missing: {out}")
        else:
            shell = app_dir / "lib" / "features" / "shell" / "pages" / "main_shell_page.dart"
            if not shell.is_file():
                # Accept alternate shell names
                shell_dir = app_dir / "lib" / "features" / "shell"
                if not shell_dir.is_dir():
                    errors.append("missing lib/features/shell (TabShell)")
            pubspec = app_dir / "pubspec.yaml"
            if not pubspec.is_file():
                errors.append("missing pubspec.yaml")
            else:
                text = pubspec.read_text(encoding="utf-8")
                if "name: app_template" in text:
                    errors.append("pubspec still named app_template; rename to product slug")

            analyze = subprocess.run(
                ["dart", "analyze", "lib"],
                cwd=app_dir,
                capture_output=True,
                text=True,
                check=False,
            )
            if analyze.returncode != 0:
                errors.append(
                    f"dart analyze failed: {(analyze.stdout or analyze.stderr).strip()[:500]}"
                )

    root = _find_root()
    if root:
        handoff_script = (
            root / "00_Orchestrator" / "app-workflow" / "scripts" / "validate_handoff.py"
        )
        if handoff_script.is_file():
            proc = subprocess.run(
                [sys.executable, str(handoff_script), str(manifest_path)],
                capture_output=True,
                text=True,
                check=False,
            )
            if proc.returncode != 0:
                errors.append(
                    f"validate_handoff failed: {(proc.stdout or proc.stderr).strip()}"
                )

    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print(
            "Usage: validate_brand_tabs_flutter.py <handoff-manifest.json>",
            file=sys.stderr,
        )
        return 2
    path = Path(sys.argv[1]).resolve()
    if not path.is_file():
        _fail(f"file not found: {path}")
        return 1
    errors = validate(path)
    if errors:
        for e in errors:
            _fail(e)
        return 1
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
