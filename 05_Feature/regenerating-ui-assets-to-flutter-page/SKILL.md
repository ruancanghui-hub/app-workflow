---
name: regenerating-ui-assets-to-flutter-page
description: >-
  Rebuild a specified Flutter screen at high fidelity from a red-box annotated UI reference and its
  regenerated code-ready asset package. Use after Flutter scaffold exists when the user wants the
  marked assets generated, packaged, and applied to one page; not for generic feature development.
---

# Regenerated Assets to Flutter Page

Turn an annotated UI reference into one high-fidelity Flutter page without baking screenshot pixels into the interface. This skill composes the existing asset-generation workflow with a focused Flutter implementation.

## Prerequisites

- A target screenshot/mockup and a Flutter project with the destination route or page identified.
- Either an approved code-ready package from `regenerating-ui-redbox-assets`, or permission to create one from the annotated reference.
- The target project is already scaffolded. Do not create a second Flutter app for this work.

## Workflow

1. **Establish the page contract.** Identify the page, route, reference canvas size, active state, and the existing controller/state that owns its interactions. Preserve the project's navigation and state-management patterns.
2. **Produce or validate the asset package.** When the package is absent or incomplete, follow [the asset skill](../../../02_IP/regenerating-ui-redbox-assets/SKILL.md) first. Reuse an accepted asset package; regenerate only missing, wrong-state, or failed assets.
3. **Map assets to Flutter.** Read `manifest.json`, copy only the page's required groups into a stable `assets/images/<page>/` tree, and register every directory in `pubspec.yaml`. Keep text, layout, and glass/surface treatments in Flutter widgets; use the PNG files for generated imagery, isolated glyphs, and background artwork.
4. **Implement the page.** Reconstruct the reference hierarchy, spacing, scale, typography, materials, and lighting with the app's existing design primitives. Size against the reference canvas with responsive constraints such as `LayoutBuilder`, not fixed device assumptions. Wire controls to existing reachable behavior; do not invent data flows solely to make a visual control functional.
5. **Verify.** Inspect the rendered target route on an available emulator/device or equivalent preview, then run the project's focused checks. Validate the asset ZIP if this run generated it. Treat pre-existing analyzer diagnostics separately from new diagnostics.

## Fidelity Contract

- A page scene and card surface called out as backgrounds remain separate background assets, never screenshots with UI baked in.
- Isolated icons retain transparent alpha and are not replaced with rectangular crops.
- Source labels remain Flutter text unless the reference explicitly needs a text artwork asset.
- Match the reference's selected state, visual weight, glow, blur, padding, and component geometry before adding unrelated polish.
- Do not modify unrelated pages, global theme architecture, or business logic unless the target page cannot render without a necessary local change.

## Deliverables

```text
output/brand-ip/<slug>/05-ui-assets/<page>/
output/brand-ip/<slug>/05-ui-assets/<page>-assets.zip
<flutter_app>/assets/images/<page>/
<flutter_app>/lib/features/<feature>/pages/<page>_page.dart
```

Update `docs/workflow/<slug>/handoff-manifest.json` when it exists:

```json
"phases": {
  "features": {
    "asset_page_dir": "lib/features/<feature>/pages/<page>_page.dart",
    "asset_page_assets": "output/brand-ip/<slug>/05-ui-assets/<page>",
    "asset_page_status": "PASS"
  }
}
```

Read [workflow integration](references/workflow-integration.md) when this skill is invoked by `app-workflow`.
