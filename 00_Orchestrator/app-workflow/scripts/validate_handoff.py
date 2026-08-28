#!/usr/bin/env python3
"""Validate app-workflow handoff-manifest.json structure and gate consistency."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

REQUIRED_TOP = {
    "schema_version",
    "product_slug",
    "workflow",
    "intake",
    "metadata",
    "mvp_loop",
    "phases",
    "gates",
}

REQUIRED_METADATA = {"产品名", "模式", "平台", "目标用户", "商业策略"}

GATE_ORDER = (
    "prd",
    "ip",
    "prototype",
    "flutter_scaffold",
    "features",
    "qa",
    "app_store",
)


def _fail(msg: str) -> None:
    print(f"FAIL: {msg}")


def _check_path(manifest_path: Path, rel: str, label: str, errors: list[str]) -> None:
    if not rel:
        errors.append(f"{label}: path is empty")
        return
    target = (manifest_path.parent / rel).resolve() if not Path(rel).is_absolute() else Path(rel)
    if not target.exists():
        errors.append(f"{label}: missing path {rel}")


def validate(manifest: dict[str, Any], manifest_path: Path) -> list[str]:
    errors: list[str] = []

    missing = REQUIRED_TOP - set(manifest)
    if missing:
        errors.append(f"missing top-level keys: {sorted(missing)}")
        return errors

    version = manifest.get("schema_version")
    if version not in (1, 2):
        errors.append("schema_version must be 1 or 2")

    slug = manifest.get("product_slug", "")
    if not slug or not str(slug).replace("_", "").isalnum():
        errors.append("product_slug must be non-empty filesystem-safe snake_case")

    meta = manifest.get("metadata", {})
    for key in REQUIRED_METADATA:
        if not meta.get(key):
            errors.append(f"metadata.{key} is empty")

    gates: dict[str, str] = manifest.get("gates", {})
    for gate in GATE_ORDER:
        status = gates.get(gate, "PENDING")
        if status not in ("PENDING", "PASS", "FAIL"):
            errors.append(f"gates.{gate} must be PENDING, PASS, or FAIL")

    for i, gate in enumerate(GATE_ORDER):
        if gates.get(gate) == "PASS":
            for prior in GATE_ORDER[:i]:
                if gates.get(prior) != "PASS":
                    errors.append(f"gates.{gate}=PASS but gates.{prior} is not PASS")

    phases = manifest.get("phases", {})

    if gates.get("prd") == "PASS":
        prd = phases.get("prd", {})
        prd_dir = prd.get("dir", "")
        if not prd_dir:
            errors.append("phases.prd.dir required when gates.prd=PASS")
        else:
            _check_path(manifest_path, prd_dir, "phases.prd.dir", errors)
            for name, rel in (prd.get("files") or {}).items():
                if rel:
                    _check_path(manifest_path, rel, f"phases.prd.files.{name}", errors)
        if not manifest.get("mvp_loop"):
            errors.append("mvp_loop required when gates.prd=PASS")

    if gates.get("ip") == "PASS":
        brand = phases.get("brand", {})
        for key in ("delivery_dir", "icon_path", "launch_screen_path"):
            val = brand.get(key, "")
            if val:
                _check_path(manifest_path, val, f"phases.brand.{key}", errors)
        if brand.get("direction_id") is None:
            errors.append("phases.brand.direction_id required when gates.ip=PASS")
        if brand.get("tab_ui_direction") is None:
            errors.append("phases.brand.tab_ui_direction required when gates.ip=PASS")

    if gates.get("prototype") == "PASS":
        proto = phases.get("prototype", {})
        proto_dir = proto.get("dir", "docs/prototype")
        _check_path(manifest_path, proto_dir, "phases.prototype.dir", errors)
        if not proto.get("traceability_rows"):
            errors.append("phases.prototype.traceability_rows must be > 0 when gates.prototype=PASS")

    if gates.get("flutter_scaffold") == "PASS":
        flutter = phases.get("flutter", {})
        out = flutter.get("output_dir", "")
        if not out:
            errors.append("phases.flutter.output_dir required when gates.flutter_scaffold=PASS")
        else:
            _check_path(manifest_path, out, "phases.flutter.output_dir", errors)

    if gates.get("features") == "PASS":
        feat = phases.get("features", {})
        trace = feat.get("implementation_trace", "")
        if not trace:
            errors.append("phases.features.implementation_trace required when gates.features=PASS")
        else:
            _check_path(manifest_path, trace, "phases.features.implementation_trace", errors)

    if gates.get("qa") == "PASS":
        qa = phases.get("qa", {})
        report = qa.get("report", "")
        if not report:
            errors.append("phases.qa.report required when gates.qa=PASS")
        else:
            _check_path(manifest_path, report, "phases.qa.report", errors)

    if gates.get("app_store") == "PASS":
        store = phases.get("app_store", {})
        for key in ("submission", "privacy"):
            val = store.get(key, "")
            if not val:
                errors.append(f"phases.app_store.{key} required when gates.app_store=PASS")
            else:
                _check_path(manifest_path, val, f"phases.app_store.{key}", errors)

    glossary = (manifest.get("domain_docs") or {}).get("glossary", "")
    if glossary and gates.get("prd") == "PASS":
        _check_path(manifest_path, glossary, "domain_docs.glossary", errors)

    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: validate_handoff.py <handoff-manifest.json>", file=sys.stderr)
        return 2

    manifest_path = Path(sys.argv[1]).resolve()
    if not manifest_path.is_file():
        _fail(f"file not found: {manifest_path}")
        return 1

    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        _fail(f"invalid JSON: {exc}")
        return 1

    errors = validate(manifest, manifest_path)
    if errors:
        for err in errors:
            _fail(err)
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
