---
name: original-image-design-json-to-flutter-page
description: Use when an annotated UI reference must first yield a content-free design-system JSON, then code-ready assets and one high-fidelity Flutter page.
---

# Original Image → Design JSON → Assets → Flutter Page

Use the original screenshot to establish a reusable visual and layout contract before regenerating marked assets and implementing one existing Flutter page. This skill extends [Regenerated Assets to Flutter Page](../regenerating-ui-assets-to-flutter-page/SKILL.md); it does not replace that skill's asset, text-bearing background, Flutter-target, or verification rules.

## Inputs

- Original screenshot (`source.*`) and its annotated counterpart (`annotated.png`).
- `annotation.json` when supplied, including the target stack, Flutter page path, and Region callout copy.
- An existing Flutter project and destination page/route for Flutter targets.

Use the original screenshot for design analysis. Use `annotated.png` only to identify assets and background callouts. Do not infer layout from red boxes or arrows.

## Workflow

1. Confirm the HandoffBundle has `source.*`, `annotated.png`, and `annotation.json`. Read the original image at its native canvas size.
2. Create `design-system-profile.json` beside `annotation.json` before generating any assets. Use a vision-capable turn with the original screenshot attached and this prompt verbatim:

   ```text
   Create a JSON-formatted design system profile. This profile should extract relevant visual design information from the provided screenshots. The JSON output must specifically include:

   The overarching design style (e.g., color palette, typography, spacing, visual hierarchy).

   The structural elements and layout principles.

   Any other attributes crucial for an AI to consistently replicate these design systems.

   Crucially, do not include the specific content or data present within the images, focusing solely on the design system itself.
   ```

3. Require valid JSON only. Exclude visible copy, names, logos, numbers, dates, user data, product data, and screenshot-specific asset descriptions. Preserve only reusable visual facts: canvas dimensions, color roles, typography roles, spacing rhythm, radii, elevation/blur, hierarchy, component geometry, regions, grids, navigation pattern, alignment, and responsive behavior.
4. Validate that the file parses and contains `meta`, `design_style`, `structure`, `components`, and `replication_notes`. `meta.content_excluded` must be `true`. If the extraction includes source content, remove it and retain the corresponding visual role instead.
5. Follow [Regenerated Assets to Flutter Page](../regenerating-ui-assets-to-flutter-page/SKILL.md) completely. Generate assets from the annotated reference and use the existing text-bearing background contract when a Region callout has `calloutCopy`.
6. Before writing Flutter, read `design-system-profile.json`, `annotation.json`, and the asset package manifest together. The design JSON defines layout hierarchy, sizing rhythm, color roles, component treatments, and responsive constraints; the original screenshot remains the visual reference; the manifest identifies image files. When they conflict, use the original screenshot as visual truth, retain the JSON's reusable role description, and record the correction in the JSON's `replication_notes`.
7. Implement the destination Flutter page with widgets and regenerated assets. Keep ordinary text as Flutter text. Do not duplicate copy embedded in an explicitly text-bearing background image; apply `Semantics` instead.
8. Verify the asset package, Flutter route, and focused checks required by the delegated Flutter-page skill. Confirm `design-system-profile.json` parses in the final bundle.

## Design JSON contract

Adapt this shape to the reference while preserving these top-level keys:

```json
{
  "meta": {
    "reference_file": "source.png",
    "canvas": { "width": 0, "height": 0 },
    "content_excluded": true
  },
  "design_style": {
    "mood": "",
    "color_roles": {},
    "typography_roles": {},
    "spacing_rhythm": {},
    "surface_treatments": {}
  },
  "structure": {
    "layout_type": "",
    "regions": [],
    "layout_principles": [],
    "responsive_behavior": []
  },
  "components": {},
  "replication_notes": []
}
```

Use roles and geometry rather than screenshot content. For example, describe `primary_title`, `secondary_metadata`, or `leading_illustration`, never the title's actual words or a recognizable logo.

## Deliverables

```text
<handoff-bundle>/design-system-profile.json
<asset-package>/manifest.json
<flutter-project>/assets/images/<page>/
<flutter-project>/lib/features/<feature>/pages/<page>_page.dart
```

Include the design-profile path in the final report with the asset and page paths. Stop before implementation when the Flutter target cannot be identified; do not create a second app.
