---
name: converting-sliced-ui-to-html-figma
description: Use when a project has UI skeleton screenshots, sliced per-page assets, and optional layout metadata that must become a fixed-fidelity clickable HTML prototype plus local Figma-importable screens.
---

# Converting Sliced UI to HTML and Figma

Use this skill when screenshots are the visual source of truth and the target is a static or clickable prototype, not a new product design.

## Inputs

Require:

- one reference screenshot per screen;
- per-screen sliced assets (backgrounds, icons, controls);
- canvas size; use layout JSON when supplied.

Treat the screenshot as visual truth and layout JSON as geometry truth. If they materially conflict, stop and ask; do not invent a reconciliation. If layout JSON is absent, read the canvas dimensions from the reference PNG, derive geometry by screenshot alignment, and record every inferred coordinate before building. Ask only when overlaps or placement remain ambiguous. Keep screenshot PNGs out of HTML content except for an explicit compare overlay.

## Build HTML

1. Create one fixed canvas per screen at the exact reference width and height; scale the outer stage proportionally only.
2. Position semantic HTML and sliced assets from layout metadata, or from the recorded inferred coordinates when metadata is absent. Save inferred coordinates in `layout-spec.json`. Use sliced backgrounds and transparent icons, not screenshot crops.
3. Preserve the navigation order and active state shown by each matching reference. Enforce one shared order only when all references agree; otherwise record the inconsistency in the delivery README and retain the supplied per-screen order. Make only supplied controls interactive; leave unspecified flows inert.
4. Include an optional opacity-controlled screenshot overlay for pixel comparison.

## Export Figma-importable screens

- If a tested Figma connector/exporter is available, use it and state the resulting file type. If the user explicitly requires a cloud-native `.fig` and no tested connector exists, stop and ask whether the local SVG import package is acceptable; never silently substitute it.
- Otherwise export one self-contained SVG per screen, with the exact canvas dimensions and the reference PNG embedded as a data URI. This is a local Figma import, not a native `.fig` or cloud document.
- Use `scripts/export_figma_svg.py INPUT.png OUTPUT.svg WIDTH HEIGHT` for the local SVG fallback.

## Verify before delivery

- Confirm every HTML screen opens at the intended fixed canvas, asset paths resolve, and declared navigation switches screens.
- Overlay the matching screenshot to inspect typography, position, layer order, and active-tab state.
- Check every SVG has the expected `width`, `height`, `viewBox`, and embedded PNG payload.
- Report any font substitution or missing input asset; never fabricate a replacement.
