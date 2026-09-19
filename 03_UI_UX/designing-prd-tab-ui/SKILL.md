---
name: designing-prd-tab-ui
description: Use when an App PRD and MVP scope need to become functionally grounded root Tab UI designs, tab specifications, or brand-aligned mobile screen concepts before prototyping or implementation.
---

# Designing PRD Tab UI

Turn approved product documents into root Tab designs that visibly carry MVP functions and states. This is the bridge from Phase 2 brand imagery to Phase 3 prototype work; it does not build product code.

## Inputs

Read the product feature list, PRD, MVP scope, and workflow handoff. Require `gates.prd = PASS`. If brand imagery is available, read its character lock and selected Tab-shell contract before designing; preserve the approved identity without making the mascot a substitute for functionality.

## Workflow

1. Extract each current-release root Tab in its declared order. For every Tab, map P0 requirements, primary action, secondary entries, and empty, offline, permission, and entitlement states. Put the result in `04-core-tab-ui/tab-function-design.md` under the brand delivery directory.
2. Keep P1/P2 features out of the MVP root screens unless the product document explicitly requires them. Record deferred destinations; do not invent a root Tab.
3. Design one root-screen concept per declared Tab. A concept shows the actual function hierarchy, not generic cards:
   - Today/overview: primary metric, result structure, period view, and the next useful action.
   - App/rule management: list state, add/remove, entitlement limit, permission state, and recovery entry.
   - Settings/profile: defaults, language, billing restore, privacy, help, and local-data controls where applicable.
4. If generating raster concepts, use `imagegen`; repeat the brand lock, tab purpose, and exact P0 scope in every prompt. Use a common navigation shell whose labels/order remain unchanged. Generated text is a visual reference: record its intended strings in the function design, and use native text in prototypes and production.
5. Freeze the selected root page. Read [reference workflow](references/workflow.md) before expanding the remaining root pages or updating the handoff.
6. Inspect for PRD coverage, root order, primary action, permission recovery, entitlements, and excluded scope. A wrong IA or missing P0 state is a failure; cosmetic raster variation is recorded as a limitation.

## Outputs

- `04-core-tab-ui/tab-function-design.md`
- `04-core-tab-ui/core_tab_ui/00-style-lock.md`
- one raster visual reference per root Tab when imagery is requested
- `04-core-tab-ui/core_tab_ui/qa-report.md`

Pass this package to `creating-app-prototypes` for editable screens, interaction states, traceability, and navigation verification.
