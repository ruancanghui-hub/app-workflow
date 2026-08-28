---
name: app-workflow
description: >-
  一句话启动完整 App 工作流：PRD → 品牌 IP → UI/UX 原型 → Flutter 脚手架 → 功能实现 → QA 打磨 → App Store 提审；
  并通过规则之三将重复步骤沉淀为 Playbook，持续进化流水线。
  Use when the user wants to build an app end-to-end, run the full pipeline, 一句话建 App,
  app-workflow, or orchestrate all workflow phases through App Store submission.
---

# App Workflow Orchestrator

将用户的一句话产品意图，编排为**七个可验证阶段 + 持续进化环**。每阶段只向下游传递**文件契约**，不靠聊天记忆串联。任一质量门未 PASS，不得进入下一阶段。每个 Gate 通过后执行 `evolve-workflow` 阶段回顾。

## Child skills (do not reimplement)

| Phase | Skill directory | Skill name |
|-------|-----------------|------------|
| 1 PRD | `01_PRD/creating-app-product-docs/` | `creating-app-product-docs` |
| 2 IP | `02_IP/APP品牌IP生成/` | `generate-app-brand-ip` |
| 3 UI/UX | `03_UI_UX/creating-app-prototypes/` | `creating-app-prototypes` |
| 4 Scaffold | `04_Dev/create-flutter-app/` | `create-flutter-app` |
| 5 Features | `05_Feature/implement-flutter-features/` | `implement-flutter-features` |
| 6 QA | `06_QA/polish-app-quality/` | `polish-app-quality` |
| 7 App Store | `07_AppStore/release-to-app-store/` | `release-to-app-store` |
| ∞ Evolution | `08_Learn/evolve-workflow/` | `evolve-workflow` |

Read each child `SKILL.md` in full before executing that phase. This orchestrator defines **order, gates, handoff, failure policy, and evolution hooks**.

## Core principle

Research and define before generating visuals or code. Preserve verified competitor baseline. One MVP loop. Every stage leaves auditable artifacts. Smooth UX is specified in prototype interaction docs, not invented during Flutter coding.

## Start

1. Inspect the workspace; preserve existing files.
2. Parse the user brief: competitor links/names, one-sentence differentiation, platform preference, and mode.
3. If mode is absent, ask once:

   - **A. 智能模式（快速产出，子技能最多三个关键问题）**
   - **C. 深度访谈模式（逐项确认后产出）**

   Never silently choose a mode. When switching from 智能模式 to 深度访谈模式, preserve confirmed facts in `assumptions.md` and the handoff manifest.

4. Create or update the workflow root:

   ```
   docs/workflow/<product_slug>/
   ├── handoff-manifest.json
   ├── glossary.md
   └── adr/
   ```

5. Copy `assets/handoff-manifest.template.json` to `docs/workflow/<product_slug>/handoff-manifest.json` and fill `intake` before Phase 1.

## Intake contract (one-sentence entry)

Minimum user input:

```text
/app-workflow 智能模式
参考：<竞品链接或名称>
我想做：<一句话差异化>
平台：<iOS 优先 | 双端 | Android 优先>
```

Infer conservatively; record every inference in the product `assumptions.md` and `handoff-manifest.json` → `intake.inferences`.

Select a filesystem-safe `product_slug` (snake_case, ASCII). Use the same slug for Flutter `--project-name` unless the user overrides.

## State machine

```
INTAKE
  → PHASE_1_PRD → GATE_PRD
  → PHASE_2_IP ─────────────┐
  → GATE_IP                 │
  → PHASE_3_PROTOTYPE       │  Phase 3 build waits for IP direction
  → GATE_PROTOTYPE          │
  → PHASE_4_FLUTTER_SCAFFOLD┘
  → GATE_FLUTTER_SCAFFOLD
  → PHASE_5_FEATURES
  → GATE_FEATURES
  → PHASE_6_QA
  → GATE_QA
  → PHASE_7_APP_STORE
  → GATE_APP_STORE
  → COMPLETE

EVOLUTION (continuous): after every GATE_* → evolve-workflow 阶段回顾
```

Update `handoff-manifest.json` → `workflow.phase` after every transition. Use `schema_version: 2` for new projects.

## Phase 1 — PRD (`creating-app-product-docs`)

**Goal:** Five validated product documents plus a testable MVP loop.

**Execute:** Follow `01_PRD/creating-app-product-docs/SKILL.md` exactly.

**Outputs (required):**

```
docs/product/YYYY-MM-DD-<产品名>/
├── 01-功能清单.md
├── 02-PRD.md
├── 03-MVP范围.md
├── sources.md
└── assumptions.md
```

**Gate:**

```bash
python3 01_PRD/creating-app-product-docs/scripts/validate_product_docs.py \
  docs/product/YYYY-MM-DD-<产品名>/
```

Must print `PASS`. On failure: fix documents, rerun, do not proceed.

**Handoff updates:** Set `phases.prd` paths, metadata (产品名、模式、平台、目标用户、商业策略), `mvp_loop`, and `gates.prd = "PASS"`.

**Domain docs:** Seed `glossary.md` with product name, user roles, core entities, and MVP states. Add `adr/001-mvp-loop.md` summarizing the chosen hypothesis and veto conditions from `03-MVP范围.md`.

## Phase 2 — Brand IP (`generate-app-brand-ip`)

**Goal:** One coherent mascot-led brand system aligned to the PRD promise.

**Prerequisites:** `gates.prd == "PASS"`.

**Inputs:** `02-PRD.md`, `03-MVP范围.md` (authoritative).

**Execute:** Follow `02_IP/APP品牌IP生成/SKILL.md`. Required companions: `imagegen`, and `creative-production:produce` when available.

**Outputs:** Delivery tree with canonical character anchor, App Icon, launch screen, 15-action sheet, three core-Tab UI directions, ZIP + manifest + QA report.

**Gate:** Visual inspection of every asset; `pack_delivery.py` ZIP test succeeds. Set `gates.ip = "PASS"`.

**Handoff updates:** Record `phases.brand.direction_id`, `tab_ui_direction`, and absolute paths to icon, launch screen, and selected Tab UI reference.

**Failure policy:** If Tab UI directions conflict with PRD IA, stop and reconcile with PRD before Phase 3 build.

## Phase 3 — UI/UX prototype (`creating-app-prototypes`)

**Goal:** Reviewable prototype package with full interaction states — this is where “丝滑” is defined.

**Prerequisites:** `gates.prd == "PASS"`. Phase 3 **build** requires `gates.ip == "PASS"` and a selected `tab_ui_direction`.

**Inputs:**

- `01-功能清单.md`, `02-PRD.md`, `03-MVP范围.md`
- Brand assets from Phase 2 (icon palette, character, selected Tab direction)
- Competitor screenshots captured per child skill rules

**Execute:** Follow `03_UI_UX/creating-app-prototypes/SKILL.md`.

**Outputs:**

```
docs/prototype/
├── 00-需求追溯矩阵.md
├── 01-低保真原型说明.md
├── 02-交互说明文档.md
├── 03-页面跳转逻辑图.md
├── 04-原型评审清单.md
└── cdb/   # local CDB project when implementation is in scope
```

**Gate:**

```bash
python3 03_UI_UX/creating-app-prototypes/scripts/validate_prototype_package.py <project-root>
```

Plus CDB preflight and every declared navigation transition. Set `gates.prototype = "PASS"`.

**Handoff updates:** Record `phases.prototype.dir`, traceability row count, and NFR targets copied from PRD (launch time, animation, offline behavior).

**Interaction minimum for “丝滑”:** Every MVP page documents loading, empty, error, permission-denied, and interruption recovery in `02-交互说明文档.md`.

## Phase 4 — Flutter scaffold (`create-flutter-app`)

**Goal:** Runnable template instance with brand assets wired; ready for feature implementation.

**Prerequisites:** `gates.prototype == "PASS"`.

**Inputs from handoff:**

| Parameter | Source |
|-----------|--------|
| `output_dir` | Default `apps/<product_slug>/` — must not already exist |
| `--project-name` | `product_slug` |
| `--org` | User or team domain; confirm if missing |
| `--app-id` | `<product_slug>_v1` unless specified |
| `--app-name` | PRD 产品名 |
| Icon / launch | Phase 2 delivery paths |

**Preflight:** Confirm `flutter-app-template/` exists. If missing, clone https://github.com/ruancanghui-hub/yunyao or ask the user for the template path. Do not proceed without the template.

**Execute:** Follow `04_Dev/create-flutter-app/SKILL.md`:

```bash
cd flutter-app-template
./scripts/verify_template_layout.sh --strict
./scripts/create_from_template.sh <output_dir> \
  --project-name <product_slug> \
  --org <org> \
  --app-id <app_id> \
  --app-name "<app_name>"
cd <output_dir>
flutter test
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
```

**Post-scaffold (orchestrator responsibilities):**

1. Copy App Icon and launch image from Phase 2 into `ios/Runner/Assets.xcassets` and Android `mipmap`/`drawable` per platform conventions.
2. Create `.scratch/<app-name>/` with a feature checklist derived from `00-需求追溯矩阵.md` (one row per `lib/features/<feature>/`).
3. Do **not** modify `flutter-app-template/template/`.

**Gate:** New directory exists; `dart analyze` clean; `flutter test` passes. Set `gates.flutter_scaffold = "PASS"`.

**Evolution hook:** Ask if scaffold setup had repeatable friction; `log_repetition.py` if yes.

## Phase 5 — Feature implementation (`implement-flutter-features`)

**Goal:** MVP P0 traceability rows implemented in Flutter with tests.

**Prerequisites:** `gates.flutter_scaffold == "PASS"`.

**Execute:** Follow `05_Feature/implement-flutter-features/SKILL.md`.

**Outputs:** `docs/workflow/<product_slug>/implementation-trace.md`, `lib/features/*`, updated `.scratch/<app-name>/feature-checklist.md`.

**Gate:**

```bash
python3 05_Feature/implement-flutter-features/scripts/validate_feature_implementation.py \
  <flutter_app_dir> \
  docs/workflow/<product_slug>/implementation-trace.md
```

Set `gates.features = "PASS"`; update `phases.features.*` in handoff.

**Evolution hook:** Log any step you repeated for the third time (e.g. route wiring, permission flow).

## Phase 6 — QA polish (`polish-app-quality`)

**Goal:** Measurable smooth UX on real device; all P0 interaction states verified.

**Prerequisites:** `gates.features == "PASS"`.

**Execute:** Follow `06_QA/polish-app-quality/SKILL.md`.

**Outputs:** `docs/workflow/<product_slug>/qa-report.md`.

**Gate:**

```bash
python3 06_QA/polish-app-quality/scripts/validate_qa_report.py \
  docs/workflow/<product_slug>/qa-report.md
```

Set `gates.qa = "PASS"`; update `phases.qa.*` in handoff.

**Evolution hook:** Promote recurring QA setup (simulator profiles, network conditioning) to playbooks.

## Phase 7 — App Store release (`release-to-app-store`)

**Goal:** Complete submission package uploaded and submitted for review.

**Prerequisites:** `gates.qa == "PASS"`.

**Execute:** Follow `07_AppStore/release-to-app-store/SKILL.md`.

**Outputs:**

```
docs/workflow/<product_slug>/
├── app-store-submission.md
├── privacy-questionnaire.md
└── screenshots/
```

**Gate:**

```bash
python3 07_AppStore/release-to-app-store/scripts/validate_app_store_package.py \
  docs/workflow/<product_slug>/app-store-submission.md
```

Set `gates.app_store = "PASS"` when submission is testflight/submitted/approved. Update `phases.app_store.*`.

**Note:** PASS means submission package complete and sent — not Apple approval.

**Evolution hook:** Promote repeated cert/screenshot/privacy steps.

## Phase ∞ — Workflow evolution (`evolve-workflow`)

Runs **after every gate** and whenever the user says a step feels repetitive.

**Registry:** `00_Orchestrator/app-workflow/registry/repetition-log.json`

**Playbooks:** `00_Orchestrator/app-workflow/playbooks/` — see `INDEX.md`

**Rule of three:** Same pattern logged 3 times → mandatory `promote_to_playbook.py` → merge into child Skill `references/` or orchestrator phase section.

```bash
python3 08_Learn/evolve-workflow/scripts/log_repetition.py \
  --phase features --pattern "..." --context "..." --product-slug <slug>

python3 08_Learn/evolve-workflow/scripts/promote_to_playbook.py \
  --pattern-id <id> --title "..."
```

Before starting any phase, check `playbooks/INDEX.md` for applicable playbooks and apply them first.

## Handoff manifest

Single source of truth: `docs/workflow/<product_slug>/handoff-manifest.json`.

Template: `assets/handoff-manifest.template.json`.

After each gate, run:

```bash
python3 00_Orchestrator/app-workflow/scripts/validate_handoff.py \
  docs/workflow/<product_slug>/handoff-manifest.json
```

Fix all reported issues before claiming phase completion.

## Failure policy

| Failure | Action |
|---------|--------|
| PRD validator FAIL | Stay in Phase 1 |
| IP assets incomplete | Progress update only; no Phase 3 build |
| Prototype missing interaction states | Extend `02-交互说明文档.md`; no Flutter |
| `verify_template_layout.sh` FAIL | Fix template source; do not force-create instance |
| `output_dir` already exists | New slug or explicit user consent to use another path |
| PRD ↔ prototype traceability gap | Add rows to `00-需求追溯矩阵.md` before scaffold |
| Feature trace incomplete | Stay in Phase 5 |
| QA blocker open | Stay in Phase 6 or return to Phase 5 |
| App Store rejection (bug) | Phase 5/6 per `ios-release-checklist.md` |
| Repetition count ≥ 3 | Run `promote_to_playbook.py` before next project |

Never overwrite `docs/product/*` or `docs/prototype/` silently; use numeric suffix directories per child skill rules.

## Final response (workflow complete through Phase 7)

Lead with completion scope. Provide:

1. Link `handoff-manifest.json`, `glossary.md`, and `playbooks/INDEX.md` if updated
2. Links to all phase output roots
3. MVP loop one-liner; TestFlight / submission status
4. Every gate status (`PASS` / pending)
5. Exact `flutter run` and `flutter build ipa` commands
6. New playbooks promoted this run

Do not claim Apple approval until `submission_status: approved`.

## Example

User:

```text
/app-workflow 智能模式
参考：Tide
我想做：睡前心率+呼吸辅助的轻冥想 App
平台：iOS 优先
```

1. Create `docs/workflow/yunyao_sleep/handoff-manifest.json`
2. Run Phase 1 → five product files → validator PASS
3. Run Phase 2 → brand ZIP → gate PASS
4. Run Phase 3 → prototype package → validator PASS
5. Run Phase 4 → `apps/yunyao_sleep` → analyze + test PASS
6. Run Phase 5 → implementation-trace → validator PASS
7. Run Phase 6 → qa-report → validator PASS
8. Run Phase 7 → TestFlight + submit → validator PASS
9. Report handoff, playbooks, and submission status

## Common mistakes

- Skipping validators and claiming the workflow is done.
- Starting IP or prototype before PRD PASS.
- Building Flutter UI without `00-需求追溯矩阵.md`.
- Copying competitor branding, UI, or assets.
- Treating scaffold creation as a shippable App Store build.
- Losing metadata consistency (产品名、模式、平台、目标用户、商业策略) across phases.
- Ignoring the rule of three — repetition stays in chat instead of playbooks.
