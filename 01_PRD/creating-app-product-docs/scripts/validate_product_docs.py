#!/usr/bin/env python3
"""Validate the deterministic structure of product-planning deliverables."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


REQUIRED_FILES = {
    "01-功能清单.md": [
        "优先级定义",
        "功能总览",
        "竞品基线",
        "用户特色",
        "公共基础与合规",
        "明确不做或 R&D",
    ],
    "02-PRD.md": [
        "背景与机会",
        "产品定位",
        "用户与 JTBD",
        "目标与非目标",
        "成功指标",
        "信息架构",
        "核心流程",
        "功能需求",
        "业务规则",
        "数据与隐私",
        "异常与降级",
        "非功能需求",
        "商业化与增长",
        "埋点与实验",
        "测试与发布门",
        "风险与应对",
        "版本路线",
        "决策记录",
    ],
    "03-MVP范围.md": [
        "验证假设",
        "目标用户",
        "In Scope",
        "Out of Scope",
        "最小内容与数据对象",
        "关键页面",
        "验收标准",
        "工作包",
        "灰度发布",
        "后续扩张",
        "发布否决条件",
    ],
    "sources.md": ["来源表", "未核实信息"],
    "assumptions.md": ["用户明确提供", "来源确认", "技能推定", "待验证事项"],
}

MAIN_FILES = ("01-功能清单.md", "02-PRD.md", "03-MVP范围.md")
METADATA_FIELDS = ("产品名", "模式", "平台", "目标用户", "商业策略")
PLACEHOLDER_RE = re.compile(
    r"\b(?:TODO|TBD|PLACEHOLDER)\b|\[\s*(?:待补充|待填写)\s*\]|待补充",
    re.IGNORECASE,
)
TEMPLATE_TOKEN_RE = re.compile(r"\{\{[A-Z][A-Z0-9_]*\}\}")
HEADING_RE = re.compile(r"^#{2,6}\s+(.+?)\s*$", re.MULTILINE)
NUMBER_PREFIX_RE = re.compile(r"^\d+(?:\.\d+)*[.、]?\s*")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate files, sections, placeholders, sources, and shared metadata."
    )
    parser.add_argument("document_directory", type=Path)
    return parser.parse_args()


def normalized_headings(text: str) -> list[str]:
    return [NUMBER_PREFIX_RE.sub("", value).strip() for value in HEADING_RE.findall(text)]


def parse_metadata(text: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for field in METADATA_FIELDS:
        match = re.search(rf"^-\s*{re.escape(field)}[：:]\s*(.+?)\s*$", text, re.MULTILINE)
        if match:
            values[field] = match.group(1).strip()
    return values


def has_source_row(text: str) -> bool:
    for line in text.splitlines():
        stripped = line.strip()
        if not (stripped.startswith("|") and stripped.endswith("|")):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if not cells or cells[0] in {"页面标题", "---"}:
            continue
        if all(set(cell) <= {"-", ":"} for cell in cells if cell):
            continue
        return True
    return False


def validate(root: Path) -> list[str]:
    errors: list[str] = []
    texts: dict[str, str] = {}

    if not root.is_dir():
        return [f"document directory does not exist: {root}"]

    for filename, sections in REQUIRED_FILES.items():
        path = root / filename
        if not path.is_file():
            errors.append(f"missing required file: {filename}")
            continue
        text = path.read_text(encoding="utf-8")
        texts[filename] = text
        if not text.strip():
            errors.append(f"empty required file: {filename}")
            continue
        if PLACEHOLDER_RE.search(text):
            errors.append(f"placeholder found in {filename}")
        if TEMPLATE_TOKEN_RE.search(text):
            errors.append(f"unreplaced template token found in {filename}")
        headings = normalized_headings(text)
        for section in sections:
            if not any(section.casefold() in heading.casefold() for heading in headings):
                errors.append(f"missing section in {filename}: {section}")

    for filename in MAIN_FILES:
        if filename not in texts:
            continue
        metadata = parse_metadata(texts[filename])
        for field in METADATA_FIELDS:
            if not metadata.get(field):
                errors.append(f"missing metadata in {filename}: {field}")

    for field in METADATA_FIELDS:
        values = {
            filename: parse_metadata(texts[filename]).get(field)
            for filename in MAIN_FILES
            if filename in texts and parse_metadata(texts[filename]).get(field)
        }
        if len(set(values.values())) > 1:
            detail = "; ".join(f"{name}={value}" for name, value in values.items())
            errors.append(f"inconsistent metadata field {field}: {detail}")

    if "sources.md" in texts and not has_source_row(texts["sources.md"]):
        errors.append("sources.md has no concrete source row")

    return errors


def main() -> int:
    args = parse_args()
    root = args.document_directory.expanduser().resolve()
    errors = validate(root)
    if errors:
        print(f"FAIL: {len(errors)} validation issue(s) in {root}")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"PASS: product documents are structurally valid: {root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
