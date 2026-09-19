---
name: brand-ip-tabs-to-flutter
description: >-
  品牌 IP 与 core Tab UI 已锁定后，补最小原型过门、创建 Flutter 脚手架并实现共享 TabShell 根页面。
  Use when brand IP is done, core_tab_ui exists, user wants Flutter scaffold from Tab UI,
  brand-ip-tabs-to-flutter, or IP完成后按Tab建Flutter工程.
---

# Brand IP Tabs → Flutter App

From `gates.ip = PASS` + approved `04-core-tab-ui/`, deliver a runnable Flutter app with one shared Tab shell and every PRD root Tab page. Stops before QA / App Store.

## Core principle

Do not bake whole-screen screenshots into Flutter. Rebuild with native text and one shared Tab component per style-lock / `PASS_WITH_RASTER_LIMITATION`. System-level intercept may be **simulated** in this phase; record deferred OS work in the implementation trace.

## Prerequisites

Read [references/prerequisites.md](references/prerequisites.md). Hard requirements:

- `gates.prd == PASS` and `gates.ip == PASS`
- `phases.brand.core_tab_ui_dir` exists with style-lock + root Tab references
- `tab-function-design.md` (or equivalent) listing root Tabs

## Workflow

### 1. Minimal Phase 3 if needed

If `gates.prototype != PASS`, create a **minimal** `docs/prototype/` package that passes:

```bash
python3 "$APP_WORKFLOW_ROOT/03_UI_UX/creating-app-prototypes/scripts/validate_prototype_package.py" <workspace>
```

Include F0x traceability, interaction states (loading/empty/error/permission-denied/interruption), and navigation Mermaid. CDB HTML is not required unless the validator demands it.

Set `gates.prototype = PASS` and `traceability_rows > 0` in handoff.

### 2. Ensure flutter-app-template (latest main)

Always sync before scaffold — do not reuse stale local copies:

```bash
bash "$APP_WORKFLOW_ROOT/00_Orchestrator/app-workflow/scripts/sync_flutter_app_template.sh"
```

Then follow `04_Dev/create-flutter-app/SKILL.md` (Forui + Umeng-capable template on yunyao `main`).

### 3. Scaffold

```bash
cd "$APP_WORKFLOW_ROOT/flutter-app-template"
./scripts/verify_template_layout.sh --strict
./scripts/create_from_template.sh <workspace>/apps/<product_slug> \
  --project-name <product_slug> \
  --org <org> \
  --app-id <product_slug>_v1 \
  --app-name "<App Name>"
```

Default org when unset: `com.<product_slug>`. Copy Brand icon / launch into iOS Assets and Android mipmap/drawable. Rename package to `product_slug` if the template left `app_template`.

Gate: `dart analyze` clean (or warnings-only policy of the template) and `flutter test` pass → `gates.flutter_scaffold = PASS`.

### 4. Implement Tab shell + pages

Read [references/tab-shell-contract.md](references/tab-shell-contract.md).

1. One shared `MainShellPage` / TabShell (root order from style-lock).
2. One page per root Tab from `tab-function-design.md`.
3. Full-screen intervention routes that are **not** root Tabs (e.g. breath / intent).
4. Local store for demo loop: add guarded app → simulate open → intervention → continue/abandon → today stats.
5. Locale switch if PRD requires bilingual settings.
6. Update `.scratch/<AppName>/feature-checklist.md` and `docs/workflow/<slug>/implementation-trace.md`.

Do **not** claim full `gates.features = PASS` unless `implement-flutter-features` validator requirements are met for all P0 rows. Prefer leaving `features` PENDING with an honest trace of deferred OS intercept.

### 5. Validate

```bash
python3 "$APP_WORKFLOW_ROOT/04_Dev/brand-ip-tabs-to-flutter/scripts/validate_brand_tabs_flutter.py" \
  docs/workflow/<slug>/handoff-manifest.json
```

Must print `PASS`. Also run `validate_handoff.py`.

## Final response

Link apps path, core_tab_ui contract, implementation-trace, gate statuses (`prototype`, `flutter_scaffold`), and `flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json`. Invite Phase 5 full features or QA — do not auto-start.

## Common mistakes

- Skipping prototype gate
- Using full-page PNG as the UI tree
- Claiming features PASS without OS intercept while matrix still lists it as done
- Creating a second Flutter app when one already exists at `apps/<slug>`
