# Phase 2: product docs → brand IP

## Entry and workspace

Use this entry when an existing project asks to continue from docs into Phase 2. The workflow repository stores skills; the consuming project stores deliverables. Capture the absolute project root before invoking scripts. Do not change into the workflow repository and then write relative `docs/` or `output/` paths there.

Resolve the workflow repository from this skill's physical directory (three parents above this reference), or from `app-workflow-root` under `~/.cursor/skills` / `${CODEX_HOME:-~/.codex}/skills`. Use Python `Path.resolve()` when resolving symlinks across hosts.

## Resume contract

1. Find `docs/workflow/*/handoff-manifest.json`. Select the product named by the user; ask only if several products remain plausible. Resolve relative `phases.prd` paths against the manifest directory, not the shell working directory.
2. Read the PRD, MVP scope, feature list and assumptions in full. Reuse confirmed mode, platform, locales and product slug. 智能模式 is not authorization to auto-select a mascot. A request to enter Phase 2 already authorizes starting Phase 2; do not repeat the BA continuation question.
3. Require `gates.prd == "PASS"` and run the existing validators with absolute paths:

   ```text
   python3 <workflow-root>/01_PRD/creating-app-product-docs/scripts/validate_product_docs.py <product-docs-dir>
   python3 <workflow-root>/00_Orchestrator/app-workflow/scripts/validate_handoff.py <manifest>
   ```

   If validation fails, report the concrete issue and keep IP pending. If no handoff exists, use the orchestrator intake/template and validate product docs before entering Phase 2; do not infer PASS from file presence.
4. Read the orchestrator playbook index and applicable IP playbook. Update `workflow.phase` to `PHASE_2_IP`, preserve unrelated state, and use the real update time.
5. Write `00-strategy/prd-brief.md` and `three-ip-directions.md` under `<project-root>/output/brand-ip/<slug>/`. Preserve prior work; use a new numbered delivery directory for an explicitly requested fresh run.
6. Present three directions and a recommendation. Unless an existing user selection or explicit fully automatic instruction applies, wait for the direction choice before image production. Keep `direction_id` null and `gates.ip` pending during selection. Continue independently authorized skill/document work while waiting.
7. Continue the parent skill's character lock, image production, inspection and packaging. Record PRD root labels/order exactly; distinguish choosing a character from choosing a Tab UI direction. Do not infer approved root-page expansion from either choice.

## Handoff at delivery

Record absolute `phases.brand.delivery_dir`, `icon_path`, `launch_screen_path`, `zip_path`, and the selected `direction_id`. Record `tab_ui_direction` only when selected; otherwise leave it null. For requested post-selection root expansion, also apply the parent skill's core Tab supplement. Optional asset packaging remains `NOT_REQUESTED` unless requested.

Set `gates.ip = "PASS"` only after the required assets, visual QA, manifest and verified ZIP exist. Strategy documents or successful generation calls alone are not a completed IP package. Run `validate_handoff.py` again after updates. Run the orchestrator's evolution review on an actual gate pass. Stop at Phase 2 when that is the user's requested scope; Phase 3 build additionally requires a selected Tab UI direction.

## Cursor and Codex

The same portable SKILL.md and references serve both hosts. Install using `bash <workflow-root>/00_Orchestrator/app-workflow/scripts/install_skills.sh all` when installation is requested. Existing symlinks to this repository receive source edits immediately; verify their resolved targets instead of reinstalling unrelated skills.

- Cursor: `/app-workflow 根据 docs 进入 Phase 2 品牌 IP` or `/generate-app-brand-ip`.
- Codex: `$app-workflow 根据 docs 进入 Phase 2 品牌 IP` or `$generate-app-brand-ip`.

Use the host's available image-generation companion. Do not hardcode a Codex-only tool identifier as a requirement for Cursor, substitute placeholders for raster deliverables, or silently switch to a paid API fallback.
