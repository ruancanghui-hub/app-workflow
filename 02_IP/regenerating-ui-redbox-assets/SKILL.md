---
name: regenerating-ui-redbox-assets
description: >-
  Use when a user uploads a UI screenshot or mockup with red rectangles marking icons, illustrations,
  controls, or when they also want the page background regenerated as separate code-ready assets.
  In app-workflow, invoke after generate-app-brand-ip skeleton/core Tab UI images are ready for
  切图、打包资源、红框标注、或 code-ready asset packaging.
---

# Regenerating UI Redbox Assets

## Overview
Turn one annotated UI screenshot into individually regenerated, code-ready visual assets. Treat red rectangles as selection marks, preserve the screenshot's visual language, generate rather than crop, and package outputs by semantic group.

**App-workflow:** Read [references/workflow-integration.md](references/workflow-integration.md) for input/output paths, handoff manifest fields, and gate criteria when running inside the app-workflow pipeline.

## When to Use
Use when the user says things like “把标红框的图标重新生成”“不用切图，直接写代码”“背景也单独生成”“打包 zip”.

Do **not** use when the user only wants literal crops; in that case crop/export instead of regenerating.

## Required Workflow
1. **Confirm target exists.** A usable screenshot/image must be present in the conversation before editing or regenerating from it.
2. **Detect selections.** Read red rectangles visually. If programmatic localization helps, run `scripts/detect_red_boxes.py` on the annotated screenshot.
3. **Inventory assets.** Name every marked asset by semantic role, not by coordinates. Example groups:
   - `ui_controls/`: search, Plus, close, play
   - `status/`: emoji, status badge
   - `feature_art/`: leaf, wave, book, moon, scene art
   - `nav_icons/`: home, sleep, meditation, sound, profile
   - `backgrounds/`: full-page background(s)
4. **Infer style from the source.** Preserve palette, material, lighting, line weight, corner language, depth, glow, and mood. Remove red annotation boxes from all outputs.
5. **Regenerate each marked item separately with image generation.** Do **not** merely crop unless explicitly requested.
   - Glyph/control icons: centered, isolated, transparent background, no text unless text is intrinsic to the asset.
   - Feature illustrations: separate PNG, keep the source card's visual language; transparent or clean standalone background as appropriate.
   - Page background: regenerate without UI, text, cards, icons, or annotations; keep original screen aspect ratio unless the user specifies another size.
6. **Code-ready output rules.** Prefer PNG. Use transparent background for isolated icons. Keep consistent visual scale and padding across the same icon family. Avoid baked-in labels for nav icons unless the user explicitly asks.
7. **Name files deterministically.** Use lowercase English snake_case, e.g. `search_button.png`, `nav_sleep.png`, `feature_wave.png`, `background_home.png`.
8. **Package by group.** Create a folder tree matching the inventory and zip the root folder. Use `scripts/package_assets.py` to verify and package if helpful.
9. **Return one download link.** Mention the number of assets and group names. If image generation limits require multiple batches, complete all batches first, then create the final combined zip.

## Fidelity Rules
- Match **style**, not screenshot pixels: regenerate the asset as a clean source image.
- Match dominant colors and contrast relationships from the reference.
- Preserve the difference between UI glyphs and content artwork: glyphs stay simple; artwork can remain detailed.
- Keep navigation icons as one coherent family: same material, stroke/volume, lighting direction, and apparent weight.
- For dark sleep/meditation UIs, preserve low-stimulation mood while maintaining enough edge contrast for code use.
- Never include red boxes, measurement overlays, coordinate labels, or screenshot chrome unless they are part of the intended asset.

## Output Contract
Minimum deliverable:

```text
assets/
  backgrounds/
  feature_art/
  nav_icons/
  status/
  ui_controls/
  manifest.json
```

`manifest.json` should list filename, group, source role, transparency expectation, and notes.

## Common Mistakes
- **Cropping instead of regenerating:** produces baked-in background/UI pixels. Regenerate instead.
- **One contact sheet instead of separate files:** user cannot drop assets directly into code. Generate one file per asset.
- **Inconsistent nav icons:** regenerate them as one visual family.
- **Background still contains UI:** regenerate a clean scene with no interface elements.
- **Wrong file naming:** avoid Chinese filenames and spaces for code-facing deliverables.
- **Premature zip:** do not package until all requested batches are complete.

## Tooling
- `scripts/detect_red_boxes.py`: optional red-box locator for screenshots.
- `scripts/package_assets.py`: validates expected group folders, writes/updates a manifest, and creates the zip.
