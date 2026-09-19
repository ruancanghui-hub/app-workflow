---
name: commercial-analysis-to-app-coverage
description: >-
  从商业分析书产出 APP 覆盖（工作流 handoff + Phase 1 五份产品文档至 GATE_PRD）。
  Use when the user provides 商业分析, business analysis, APP 覆盖, or wants PRD/MVP
  docs generated from a commercial-analysis markdown before continuing app-workflow.
---

# Commercial Analysis → App Coverage

将一份**商业分析书**对齐为可验证的 App 产品覆盖：决策共识 → `docs/workflow/<slug>/` → 委托 Phase 1 五份文档 → `gates.prd = PASS`。**不**自动进入 Phase 2+。

## Core principle

商业分析里的「PRD 草稿」不是已校验产物。护城河与功能优先级矛盾必须显式决策，禁止静默抹平。产品文档写作委托 `creating-app-product-docs`，本技能只负责入口、对齐与交接。

## Prerequisites

- `gates.prd` 尚未 PASS，或用户明确要求从新商业分析重跑覆盖（新目录 / 数字后缀，不静默覆盖）
- 工作区可读的商业分析 Markdown

## Start

1. Inspect the workspace; preserve existing files.
2. Locate the commercial analysis:
   - Prefer the file the user `@` attached
   - Else glob `**/商业分析*.md` and `**/business-analysis*.md`
   - If multiple matches, ask which one once
3. If mode is absent, ask once (same labels as app-workflow):

   - **A. 智能模式（快速产出，最多三个关键问题）**
   - **C. 深度访谈模式（逐项确认后产出）**

4. Read [references/ba-document-contract.md](references/ba-document-contract.md) and extract required fields.
5. Read [references/decision-frontier.md](references/decision-frontier.md). Run contradiction gates before drafting PRD.
6. Read [references/workflow-integration.md](references/workflow-integration.md) for handoff paths and validators.

**Completion criterion (Start):** 已选定唯一商业分析路径、模式（A/C）、并完成字段抽取表（可写在会话或临时笔记，随后落入 assumptions）。

## Decision alignment

### 智能模式

Ask at most **three** scope-changing questions total (platform, primary persona, moat-vs-MVP / wearable strategy are the usual three). Infer the rest conservatively; record every inference for `assumptions.md`.

Present each question with a **recommended answer**. Wait for answers (or「全按推荐」) before writing product docs.

### 深度访谈模式

Work the frontier in rounds per `decision-frontier.md`. Do **not** generate Phase 1 files until the user confirms the consensus checklist.

### Contradiction gate (mandatory)

Trigger decision alignment (do not silently resolve) when any of:

- Differentiation / moat described as core but feature table marks it P1 or later
- Multiple primary personas without a single MVP focus
- Own hardware / NFC bundle in P0 without validated supply path
- Medical/diagnostic claims mixed into Health & Fitness positioning

**Default recommendation when triggered:** software micro-loop as MVP; moat capabilities as P1+; one primary persona; system health APIs over own hardware for v1.

**Completion criterion:** Consensus checklist filled (see `assets/consensus-checklist.template.md`); user said go (or 智能模式三问已答).

## Workflow root

1. Choose filesystem-safe `product_slug` (snake_case ASCII) from product name.
2. Create:

   ```
   docs/workflow/<product_slug>/
   ├── handoff-manifest.json
   ├── glossary.md
   └── adr/
   ```

3. Copy `00_Orchestrator/app-workflow/assets/handoff-manifest.template.json` into the handoff path; fill `intake`, `metadata`, `workflow.mode`, `workflow.phase = PHASE_BA_COVERAGE`.
4. Seed `glossary.md` with product name, MVP user, core entities.
5. Optionally create/update workspace root `CONTEXT.md` for sharpened domain terms (glossary only, no implementation).

**Completion criterion:** handoff JSON exists with non-empty `intake.one_liner` and metadata five fields.

## Delegate Phase 1

1. Read and follow `01_PRD/creating-app-product-docs/SKILL.md` in full.
2. Pass through: confirmed consensus, competitor names/links from the BA, mode, platform, business strategy, exclusions.
3. Before research, create `docs/product/YYYY-MM-DD-<产品名>/` (numeric suffix if exists) and instantiate templates from that skill's `assets/`.
4. Run until:

   ```bash
   export APP_WORKFLOW_ROOT="$(readlink -f ~/.cursor/skills/app-workflow-root 2>/dev/null || readlink ~/.cursor/skills/app-workflow-root)"
   python3 "$APP_WORKFLOW_ROOT/01_PRD/creating-app-product-docs/scripts/validate_product_docs.py" \
     docs/product/YYYY-MM-DD-<产品名>/
   ```

   prints `PASS`.
5. Write `adr/001-mvp-loop.md` from `03-MVP范围.md` hypothesis + veto conditions.
6. Update handoff: `phases.prd.*`, `mvp_loop`, `gates.prd = PASS`, `workflow.phase = PHASE_2_IP`.

**Completion criterion:** product-docs validator PASS and handoff `gates.prd == PASS`.

## Coverage gate

From workspace root (paths relative to `docs/workflow/<slug>/handoff-manifest.json` as stored):

```bash
export APP_WORKFLOW_ROOT="$(readlink -f ~/.cursor/skills/app-workflow-root 2>/dev/null || readlink ~/.cursor/skills/app-workflow-root)"
python3 "$APP_WORKFLOW_ROOT/00_Orchestrator/app-workflow/scripts/validate_handoff.py" \
  docs/workflow/<product_slug>/handoff-manifest.json
python3 "$APP_WORKFLOW_ROOT/01_PRD/commercial-analysis-to-app-coverage/scripts/validate_ba_coverage.py" \
  docs/workflow/<product_slug>/handoff-manifest.json
```

Both must print `PASS`. On failure: fix and rerun; do not claim coverage complete.

After gate: one-line evolve-workflow stage review (log only if user reports repeated friction).

## Final response

Lead with coverage complete. Link:

1. Commercial analysis source path
2. `handoff-manifest.json`, five product docs, `glossary.md`, `adr/001-mvp-loop.md`
3. MVP loop one-liner
4. `gates.prd = PASS`; other gates PENDING
5. Invite: continue Phase 2 brand IP via `/app-workflow`

Do not start Phase 2 unless the user asks.

## Common mistakes

- Treating BA embedded PRD tables as `validate_product_docs` PASS
- Skipping contradiction gate when moat ≠ P0
- Reimplementing PRD prose inside this skill instead of delegating
- Overwriting `docs/product/*` without numeric suffix
- Auto-running brand IP / Flutter after coverage
