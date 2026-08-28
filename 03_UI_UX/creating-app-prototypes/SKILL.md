---
name: creating-app-prototypes
description: Use when a user has product-definition documents, a PRD, MVP scope, competitor links, or an app idea and wants low-fidelity prototype screens, interaction specifications, navigation logic, prototype review materials, or CDB HTML that can be sent to local Figma.
---

# Creating App Prototypes

Turn approved product definition into a reviewable mobile-app prototype package. Keep requirements traceable; use competitors only as behavioral and visual-reference evidence, never as assets to copy.

## Inputs and defaults

1. Read the feature list, PRD, and MVP scope. If they are missing, request them or equivalent product definition.
2. Inspect each named competitor/reference directly. Capture a screenshot before using it as visual grounding. Stop if a named visual reference is inaccessible.
3. Default to iPhone 390 × 844 and Android adaptation rules. Ask only if surface or user outcome is unclear.
4. Extract the MVP loop, navigation, permissions, safety boundaries, metric, and non-goals. Create the traceability table from `assets/traceability-template.md`.

## Visual selection

Use ImageGen for three independent mobile directions if no visual target is selected. Attach readable reference screenshots; preserve constraints; do not copy brand, content, or layout. Show one hero use case and one primary action per option. Wait for selection before building HTML.

## Deliverables

Create `docs/prototype/`:

- `00-需求追溯矩阵.md`: requirement → page, state, acceptance check.
- `01-低保真原型说明.md`: IA, page inventory, and annotations.
- `02-交互说明文档.md`: page actions plus loading, empty, error, permission, confirmation, refresh, pagination, back-navigation, accessibility, and privacy rules.
- `03-页面跳转逻辑图.md`: Mermaid IA, main loop, and degradation flows.
- `04-原型评审清单.md`: business, engineering, test, and handoff checks.

Write and approve a prototype specification, then a delivery plan before implementation.

## CDB/Figma implementation

Create a dependency-light local CDB project. Keep exactly one `data-codex-root` per page; keep editable nodes initially present with stable, unique `data-codex-id`; do not replace mapped nodes with `innerHTML`. Model state explicitly and provide safe fallbacks for permission denial, low-quality health data, errors, offline, and interruptions.

Use only the local CDB Figma development plugin: preflight, preview key states, then send manifest page IDs with `send_preview_to_local_figma`. Never substitute the official Figma connector.

## Health and prototype safety

For health products, show estimates, coverage, confidence, data gaps, consent and deletion. Do not claim diagnosis, treatment, medical-grade accuracy, or unavailable sensors. Mark simulated data and prototype-only behavior.

## Verification

Run `scripts/validate_prototype_package.py <project-root>`, CDB preflight, and every declared transition. Use `references/review-rubric.md` for the final review.
