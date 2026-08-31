# App-workflow integration

Use this as an optional Phase 5 supplement when a user wants one Flutter page reproduced from an annotated, asset-driven UI reference.

## Position

- Run after Phase 4 has a Flutter app and after Phase 2b has a valid page asset package, or let this skill invoke Phase 2b for the supplied annotated reference.
- It contributes to Phase 5 implementation evidence. It does not introduce a new workflow gate and does not replace `implement-flutter-features` for unrelated MVP work.

## Inputs

| Input | Source |
|---|---|
| Annotated visual reference | User upload or `output/brand-ip/<slug>/04-core-tab-ui/annotated/` |
| Code-ready assets | `output/brand-ip/<slug>/05-ui-assets/<page>/manifest.json` |
| Flutter target | `phases.flutter.output_dir` and the selected page/route |

## Handoff fields

Record these optional `phases.features` fields after successful page implementation:

```json
"asset_page_dir": "lib/features/<feature>/pages/<page>_page.dart",
"asset_page_assets": "output/brand-ip/<slug>/05-ui-assets/<page>",
"asset_page_status": "PASS"
```

`asset_page_status` is `NOT_REQUESTED`, `PENDING`, `PASS`, or `FAIL`. When `PASS`, both paths must exist.

## Acceptance

- The ZIP validates and its manifest names all page assets.
- Flutter has registered the copied asset directories.
- The target route renders with the regenerated assets and preserves the app's existing navigation/state ownership.
- Focused tests pass; report pre-existing static-analysis diagnostics without attributing them to this page.
