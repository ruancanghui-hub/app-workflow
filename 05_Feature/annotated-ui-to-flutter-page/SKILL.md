---
name: annotated-ui-to-flutter-page
description: Use when an annotated mobile UI screenshot and annotation JSON must become regenerated assets and one existing high-fidelity Flutter page, especially for red-box icon marks and background callouts.
---

# Annotated UI to Flutter Page

Turn a marked reference into one responsive Flutter route. Preserve the app's navigation and state ownership; do not create a second app or bake a screenshot into the interface.

## Contract

1. Read the annotation JSON first. Record canvas dimensions, route, active state, every `iconMark`, and every `backgroundCallout`.
2. Translate generic labels into semantic snake_case names before generating files. Treat `backgroundCallout` as a clean page or card scene, never a screenshot crop.
3. **REQUIRED SUB-SKILL:** Use `regenerating-ui-redbox-assets` when the code-ready package is absent. Generate isolated red-box icons with transparent alpha; generate feature art and backgrounds separately. Validate transparent corners and create `manifest.json` plus a ZIP.
4. Copy only the final page assets to `assets/images/<page>/`, register the directory, and retain Flutter text, surfaces, shadows, and layout in widgets.
5. Write a focused widget test before changing the page. Recreate the canvas with responsive constraints; preserve existing route and controller behavior. Do not invent data flows for visual controls.
6. Render the implemented route at the reference canvas size and compare it side by side with the approved original. Check hierarchy, geometry, spacing, type scale, selected state, materials, safe-area clearance, and asset scale. **REQUIRED SUB-SKILL:** Use `ui-ux-pro-max` for the specific mismatch (for example responsive Flutter layout, touch targets, contrast, or accessibility), then make the smallest visual correction and re-compare.
7. Verify the focused test, static analysis, ZIP contents, visual-comparison result, and the handoff fields below.

## Output

```text
output/brand-ip/<slug>/05-ui-assets/<page>/
output/brand-ip/<slug>/05-ui-assets/<page>-assets.zip
apps/<app>/assets/images/<page>/
apps/<app>/lib/features/<feature>/pages/<page>_page.dart
```

When `docs/workflow/<slug>/handoff-manifest.json` exists, set `phases.features.asset_page_dir`, `asset_page_assets`, and `asset_page_status` to `PASS` only after both paths and verification evidence exist.

## Common mistakes

- Cropping a marked icon instead of exporting a clean transparent asset.
- Leaving labels, cards, or red annotations inside image files.
- Treating text as a raster asset.
- Using fixed screen coordinates instead of responsive layout constraints.
