#!/usr/bin/env python3
"""Embed a PNG reference in a fixed-size SVG suitable for Figma import."""
import base64
import sys
from pathlib import Path


def export_svg(source: Path, output: Path, width: int, height: int) -> None:
    encoded = base64.b64encode(source.read_bytes()).decode("ascii")
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
  <image width="{width}" height="{height}" href="data:image/png;base64,{encoded}"/>
</svg>
'''
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(svg, encoding="utf-8")


def main() -> None:
    if len(sys.argv) != 5:
        raise SystemExit("Usage: export_figma_svg.py INPUT.png OUTPUT.svg WIDTH HEIGHT")
    export_svg(Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]))


if __name__ == "__main__":
    main()
