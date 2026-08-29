# Workflow integration

`composing-asset-ui-prototype` is **Phase 2c** — a 2b→3 bridge between asset packaging and full prototype delivery.

## Pipeline position

```
04-core-tab-ui/       visual contract (whole-page PNG, QA PASS)
        ↓
05-ui-assets/         decomposed PNG + manifest.json  [Phase 2b]
        ↓
06_asset_ui/          HTML composite + overlay QA        [Phase 2c — this skill]
        ↓
docs/prototype/       traceability + interaction specs  [Phase 3 — creating-app-prototypes]
```

## When the orchestrator invokes this skill

| Condition | Action |
| --- | --- |
| `ui_assets_status == "PASS"` + user requests 06_asset_ui | Run Phase 2c |
| Asset gaps found before Phase 3 | Run Phase 2c to verify |
| User skips asset packaging | Do not run — no `05-ui-assets` |

## Locked scope (do not expand in this skill)

1. **叠对照验收** — overlay QA, not pixel-perfect CSS reproduction.
2. **HTML 文本** — all labels as text nodes; PNG for icons/backgrounds only.
3. **项目级 SKILL** — lives under `03_UI_UX/`, not `~/.agents/skills/`.
4. **桥接包** — no traceability matrix, no CDB export, no interaction state catalog.

## Handoff fields

```json
{
  "phases": {
    "brand": {
      "asset_ui_prototype_dir": "output/brand-ip/<slug>/06_asset_ui",
      "asset_ui_prototype_status": "PASS",
      "layout_spec": "output/brand-ip/<slug>/06_asset_ui/layout-spec.json"
    }
  }
}
```

Status values: `NOT_REQUESTED` | `IN_PROGRESS` | `PASS` | `FAIL`.

## Gate relationship

| Check | Owner |
| --- | --- |
| Assets exist & manifest complete | `regenerating-ui-redbox-assets` (2b) |
| Reference PNG QA PASS | Brand IP / `qa-report.md` |
| 1:1 composite + overlay QA | `composing-asset-ui-prototype` (2c) |
| Interaction states & traceability | `creating-app-prototypes` (3) |

## Validator

```bash
python3 03_UI_UX/composing-asset-ui-prototype/scripts/validate_asset_ui_prototype.py \
  output/brand-ip/<slug>
```

## Flutter handoff

`layout-spec.json` `source_role` values map to widget placement hints. Asset files copy per `regenerating-ui-redbox-assets` workflow-integration.

## Reference implementation

`output/brand-ip/healing_tabs/06_asset_ui/`
