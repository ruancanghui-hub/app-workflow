# App-workflow integration

Use this skill as a **Phase 2 supplement** after `generate-app-brand-ip` produces core Tab UI images. It turns annotated UI screenshots into code-ready asset packages for Flutter scaffold and prototype implementation.

## When the orchestrator invokes this skill

- User requests **切图 / 打包资源 / 红框 / code-ready assets / 单独生成图标** after skeleton or core Tab UI images exist.
- Phase 2 IP gate is `PASS` or in progress with approved Tab UI images ready for decomposition.
- Annotated screenshots (red rectangles marking assets) are available — user-drawn or agent-assisted via `scripts/detect_red_boxes.py`.

## Input sources (from brand IP delivery)

| Source | Typical path |
|---|---|
| Reference-guided skeleton | `output/brand-ip/<slug>/04-core-tab-ui/skeleton-<tab>.png` |
| Core Tab expansion | `output/brand-ip/<slug>/04-core-tab-ui/core_tab_ui/tab-<name>.png` |
| Direction mockup (selected) | `output/brand-ip/<slug>/04-core-tab-ui/direction-0N-*.png` |
| User-annotated copy | `output/brand-ip/<slug>/04-core-tab-ui/annotated/<tab>-marked.png` |

Prefer working from **user-annotated** copies when red boxes are required. If the user has not marked boxes yet, ask them to annotate the chosen Tab UI image or offer to help inventory regions before generation.

## Output contract (app-workflow paths)

Write all deliverables under:

```text
output/brand-ip/<slug>/05-ui-assets/
├── backgrounds/
├── feature_art/
├── nav_icons/
├── status/
├── ui_controls/
├── manifest.json
└── <slug>-ui-assets.zip
```

Update `docs/workflow/<product_slug>/handoff-manifest.json`:

```json
"phases": {
  "brand": {
    "ui_assets_dir": "output/brand-ip/<slug>/05-ui-assets",
    "ui_assets_zip": "output/brand-ip/<slug>/05-ui-assets/<slug>-ui-assets.zip",
    "ui_assets_status": "PASS"
  }
}
```

## Handoff to later phases

| Downstream | Uses |
|---|---|
| Phase 3 prototype (`creating-app-prototypes`) | Nav icons, feature art, backgrounds for CDB mockups |
| Phase 4 scaffold (`create-flutter-app`) | Copy `nav_icons/` and `ui_controls/` into `assets/images/` |
| Phase 5 features (`implement-flutter-features`) | Feature art and status icons per traceability rows |

Record absolute paths in handoff manifest before claiming Phase 2 asset packaging complete.

## Tooling (resolve from skill root)

```bash
# Optional: locate red boxes on annotated screenshot
python3 "$APP_WORKFLOW_ROOT/02_IP/regenerating-ui-redbox-assets/scripts/detect_red_boxes.py" \
  output/brand-ip/<slug>/04-core-tab-ui/annotated/home-marked.png

# Package after all assets regenerated
python3 "$APP_WORKFLOW_ROOT/02_IP/regenerating-ui-redbox-assets/scripts/package_assets.py" \
  output/brand-ip/<slug>/05-ui-assets \
  output/brand-ip/<slug>/05-ui-assets/<slug>-ui-assets.zip
```

## Gate

Do not set `phases.brand.ui_assets_status = "PASS"` until:

- every requested marked asset exists as a separate PNG in the correct group folder;
- `manifest.json` lists all assets with group, dimensions, and transparency;
- ZIP validates and opens cleanly;
- no red annotation boxes remain in any output file.
