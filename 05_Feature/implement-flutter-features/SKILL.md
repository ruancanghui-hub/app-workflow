---
name: implement-flutter-features
description: >-
  按需求追溯矩阵在 Flutter 工程中实现 MVP 功能（GetX binding → controller → pages）。
  Use when scaffold exists and user wants feature development, MVP implementation,
  业务功能开发, or to complete lib/features from prototype traceability.
---

# Implement Flutter Features

将 `00-需求追溯矩阵.md` 的每一行 P0 需求，落实为可运行、可验收的 `lib/features/<feature>/` 模块。不扩 scope；不跳过 loading/empty/error 态。

## Prerequisites

- `gates.flutter_scaffold == "PASS"` in `handoff-manifest.json`
- `docs/prototype/00-需求追溯矩阵.md` 存在且行数 > 0
- Flutter 工程路径来自 `phases.flutter.output_dir`

## Inputs

| 来源 | 用途 |
|------|------|
| `00-需求追溯矩阵.md` | 实现范围与验收 |
| `02-交互说明文档.md` | 状态机、手势、降级 |
| `03-MVP范围.md` | In/Out 边界 |
| `phases.brand.*` | 色板、角色、Tab 方向 |
| `.scratch/<app-name>/feature-checklist.md` | 进度跟踪（若无则创建） |

## Core principle

One traceability row → one feature slice with tests. Implement the MVP loop end-to-end before polish. Record every repeated friction in the workflow repetition log (see `08_Learn/evolve-workflow/SKILL.md`).

## Workflow

1. Read handoff manifest, traceability matrix, interaction spec, and `04_Dev/create-flutter-app/SKILL.md` conventions.
2. Create or refresh `.scratch/<app-name>/feature-checklist.md` from `assets/feature-checklist-template.md` — one checkbox per MVP 需求 ID.
3. Create `docs/workflow/<product_slug>/implementation-trace.md` from `assets/implementation-trace-template.md`.
4. Implement in MVP loop order (not alphabetical):
   - `lib/features/<feature>/` → `binding` → `controller` → `pages` (+ `widgets/` if needed)
   - Wire routes in app router; inject ports via GetX Binding (Analytics, RemoteConfig, CrashReporter)
   - Each page: loading, empty, error per `02-交互说明文档.md`
5. After each feature slice:
   - `dart analyze` + `flutter test`
   - Update implementation-trace row: `implemented | deferred | blocked` + evidence path
   - If you hit the **same friction** a second time across projects, log it; on the **third** occurrence run `evolve-workflow`
6. When all P0 rows are `implemented` or explicitly `deferred` with user approval:

```bash
python3 05_Feature/implement-flutter-features/scripts/validate_feature_implementation.py \
  <flutter_app_dir> \
  docs/workflow/<product_slug>/implementation-trace.md
```

7. Set `gates.features = "PASS"` in handoff; rerun orchestrator handoff validator.

## Scope rules

- MVP P0 only unless user expands scope in writing.
- Do not modify `flutter-app-template/template/`.
- Do not copy competitor assets or UI verbatim.
- Health/finance: show estimates, consent, deletion — no medical claims.
- Deferrals require reason + link to PRD exclusion or ADR.

## Required outputs

```
docs/workflow/<product_slug>/
├── implementation-trace.md     # 需求 ID → 代码路径 → 状态 → 验收证据
.scratch/<app-name>/
└── feature-checklist.md
<flutter_app_dir>/
└── lib/features/<feature>/...
```

## Gate

`validate_feature_implementation.py` must print `PASS`:
- All P0 rows resolved (implemented or approved deferral)
- `dart analyze` clean on `lib/`
- `flutter test` passes
- At least one widget/integration test per critical controller path

## Final response

Lead with MVP loop walkthrough command. Link implementation-trace, list deferred items, report gate PASS, and note repetitions logged for workflow evolution.

## Common mistakes

- Building screens without traceability IDs.
- Skipping error/empty states "for later".
- Direct Firebase SDK in pages instead of injected ports.
- Claiming features complete while tests fail.
