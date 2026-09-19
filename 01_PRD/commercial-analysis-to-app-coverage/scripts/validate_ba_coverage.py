#!/usr/bin/env python3
"""Validate commercial-analysis → app coverage: handoff GATE_PRD + product docs."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def _fail(msg: str) -> None:
    print(f"FAIL: {msg}")


def _resolve(manifest_path: Path, rel: str) -> Path:
    if not rel:
        raise ValueError("empty path")
    p = Path(rel)
    if p.is_absolute():
        return p
    return (manifest_path.parent / rel).resolve()


def _find_app_workflow_root() -> Path | None:
    here = Path(__file__).resolve()
    # .../01_PRD/commercial-analysis-to-app-coverage/scripts/this.py → repo root
    candidate = here.parents[3]
    if (candidate / "00_Orchestrator" / "app-workflow").is_dir():
        return candidate
    for link in (
        Path.home() / ".cursor" / "skills" / "app-workflow-root",
        Path(Path.home() / ".codex" / "skills" / "app-workflow-root"),
    ):
        if link.exists():
            return link.resolve()
    return None


def validate(manifest_path: Path) -> list[str]:
    errors: list[str] = []
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [f"invalid JSON: {exc}"]

    if manifest.get("gates", {}).get("prd") != "PASS":
        errors.append("gates.prd must be PASS for BA coverage complete")

    if not (manifest.get("mvp_loop") or "").strip():
        errors.append("mvp_loop is empty")

    meta = manifest.get("metadata") or {}
    for key in ("产品名", "模式", "平台", "目标用户", "商业策略"):
        if not (meta.get(key) or "").strip():
            errors.append(f"metadata.{key} is empty")

    prd = (manifest.get("phases") or {}).get("prd") or {}
    prd_dir_rel = prd.get("dir") or ""
    if not prd_dir_rel:
        errors.append("phases.prd.dir is empty")
    else:
        prd_dir = _resolve(manifest_path, prd_dir_rel)
        if not prd_dir.is_dir():
            errors.append(f"phases.prd.dir missing: {prd_dir_rel}")
        else:
            required = (
                "01-功能清单.md",
                "02-PRD.md",
                "03-MVP范围.md",
                "sources.md",
                "assumptions.md",
            )
            for name in required:
                if not (prd_dir / name).is_file():
                    errors.append(f"missing product file: {name}")

    files = prd.get("files") or {}
    for key, rel in files.items():
        if not rel:
            errors.append(f"phases.prd.files.{key} is empty")
            continue
        target = _resolve(manifest_path, rel)
        if not target.is_file():
            errors.append(f"phases.prd.files.{key} missing: {rel}")

    root = _find_app_workflow_root()
    if root is None:
        errors.append("cannot locate APP_WORKFLOW_ROOT for nested validators")
        return errors

    handoff_script = root / "00_Orchestrator" / "app-workflow" / "scripts" / "validate_handoff.py"
    product_script = (
        root / "01_PRD" / "creating-app-product-docs" / "scripts" / "validate_product_docs.py"
    )

    if handoff_script.is_file():
        proc = subprocess.run(
            [sys.executable, str(handoff_script), str(manifest_path)],
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode != 0:
            errors.append(f"validate_handoff failed: {(proc.stdout or proc.stderr).strip()}")
    else:
        errors.append(f"missing {handoff_script}")

    if prd_dir_rel:
        prd_dir = _resolve(manifest_path, prd_dir_rel)
        if prd_dir.is_dir() and product_script.is_file():
            proc = subprocess.run(
                [sys.executable, str(product_script), str(prd_dir)],
                capture_output=True,
                text=True,
                check=False,
            )
            if proc.returncode != 0:
                errors.append(
                    f"validate_product_docs failed: {(proc.stdout or proc.stderr).strip()}"
                )
        elif not product_script.is_file():
            errors.append(f"missing {product_script}")

    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print(
            "Usage: validate_ba_coverage.py <handoff-manifest.json>",
            file=sys.stderr,
        )
        return 2

    manifest_path = Path(sys.argv[1]).resolve()
    if not manifest_path.is_file():
        _fail(f"file not found: {manifest_path}")
        return 1

    errors = validate(manifest_path)
    if errors:
        for err in errors:
            _fail(err)
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
