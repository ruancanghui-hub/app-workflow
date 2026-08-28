# Core Tab UI Expansion

Use this supplement after a user approves one core-Tab/home direction and asks for the remaining root pages. It converts a visual direction into a reusable implementation contract; it does not replace the three-direction exploration step.

## 1. Freeze the selected source

1. Copy the approved image without re-rendering it and record its SHA-256 hash and actual pixel dimensions.
2. Treat the approved canvas, not a default aspect ratio, as authoritative.
3. Extract a `TabShellLock` table containing:
   - ordered labels and semantic destinations;
   - shell bounds, radius, shadow, dividers, safe-area offset;
   - each icon's center, box, stroke language, label baseline and spacing;
   - palette, type scale, card radius, surface material and mascot usage.
4. The approved page remains unchanged. Never regenerate it merely to make a set look uniform.

## 2. Map root pages to the PRD

Create one row per **current release/P0 root destination**: `tab_id`, label, P0 requirements, primary action, secondary entry points, empty/offline/permission states, and explicitly excluded later-phase features. Do not invent a root Tab that is absent from the authoritative IA. If the full PRD lists P1/P2 root destinations that are absent from the approved MVP shell, keep the approved shell and record those destinations in `deferred_root_tabs`. If an approved shell omits a P0 root destination, stop for reconciliation rather than silently preferring either artifact.

## 3. Expand the selected direction

- Generate only the missing root pages and use the approved source plus character anchor as references.
- Keep the root navigation present on root pages and absent from modal/detail flows unless the platform IA explicitly requires otherwise.
- Between root pages, only the active item may change semantically. Labels, order, shell geometry, spacing, typography, safe area, and inactive states are immutable.
- Raster concepts are visual references. If generation drifts, do not claim pixel identity. The editable prototype or app must implement one shared Tab component so the invariant is deterministic.
- Put product-specific outputs in `<brand-delivery>/04-core-tab-ui/core_tab_ui/`:

```text
core_tab_ui/
├── 00-style-lock.md
├── tab-<root-1>.png
├── tab-<root-n>.png
└── qa-report.md
```

## 4. Verify at two levels

### Raster reference gate

- All canvases match the approved source dimensions.
- Labels and order match the PRD exactly.
- Visual language and scope pass manual inspection.
- The approved source copy has the same SHA-256 hash.
- Record any generative icon/geometry drift as a limitation; never call it pixel-identical.

### Editable implementation gate

- All root pages instantiate the same Tab component and token set.
- Automated structural checks prove the same DOM/component shell is reused.
- Only the active-state value changes across roots.
- Every transition in the traceability matrix works, including offline and permission-denied paths.

## 5. Handoff contract

Update the handoff manifest with:

- `tab_ui_direction`: approved direction ID;
- `tab_ui_reference`: absolute path to the untouched approved source copy;
- `core_tab_ui_requested`: `true` only when the user requested post-selection root-page expansion;
- `core_tab_ui_dir`: absolute path to the expanded set;
- `core_tab_ui_contract`: absolute path to `00-style-lock.md`;
- `core_tab_ui_status`: `PASS`, `PASS_WITH_RASTER_LIMITATION`, or `PENDING`.
- `deferred_root_tabs`: P1/P2 root destinations intentionally excluded from the current shell.

Phase 3 may start with `PASS_WITH_RASTER_LIMITATION` only when the limitation is confined to generated concept imagery and Phase 3 will enforce the shell using one shared editable component. Any wrong label, order, destination, or PRD scope remains `PENDING`.

Run the reusable validator before the Phase 2 gate:

```bash
python3 02_IP/APP品牌IP生成/scripts/validate_core_tab_ui.py \
  --source <approved-source.png> \
  --core-dir <delivery>/04-core-tab-ui/core_tab_ui \
  --tab tonight=今晚 --tab sounds=声音 --tab sleep=睡眠 --tab profile=我的 \
  --prototype-html <project>/docs/prototype/cdb/index.html
```

`--tab` is repeatable and preserves order, so the validator supports any release-specific root count and IDs. The prototype root `<nav>` must declare `data-tab-contract="shared-active-only"`, sit outside all root screen containers, and contain exactly one ordered control per declared Tab. Structural validation does not replace runtime transition review; verify every root switch and record unchanged navigation bounds in the Phase 3 checklist.
