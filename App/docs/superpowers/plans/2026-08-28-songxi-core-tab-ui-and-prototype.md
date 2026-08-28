# Songxi Core Tab UI and Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand the approved Direction 01 homepage into a locked four-tab skeleton, make the method reusable in the Brand IP workflow, and produce the Phase 3 prototype package.

**Architecture:** Treat the approved homepage as an immutable visual contract. Store product-specific tab assets under the Brand IP delivery, store reusable rules under the Brand IP skill, and implement Phase 3 as a dependency-light local prototype plus traceability documents.

**Tech Stack:** Markdown, PNG assets, static HTML/CSS/JavaScript, Python package validator.

**Spec:** `App/docs/prototype/00-视觉与根Tab锁定规格.md`

## Global Constraints

- Root tab order is exactly `今晚 → 声音 → 睡眠 → 我的`.
- The approved Tonight image is copied without visual modification.
- Only the active tab state changes between root pages.
- MVP excludes sleep staging, diagnosis, courses, stories, mixes, and focus mode.
- Every HTML page has exactly one `data-codex-root`; all editable nodes have unique stable `data-codex-id` values; JavaScript does not use `innerHTML`.

---

### Task 1: Lock and verify the four-tab visual contract

**Files:**
- Create: `App/output/brand-ip/songxi/04-core-tab-ui/core_tab_ui/00-style-lock.md`
- Create: `App/output/brand-ip/songxi/04-core-tab-ui/core_tab_ui/tab-tonight.png`
- Create: `App/output/brand-ip/songxi/04-core-tab-ui/core_tab_ui/tab-sounds.png`
- Create: `App/output/brand-ip/songxi/04-core-tab-ui/core_tab_ui/tab-sleep.png`
- Create: `App/output/brand-ip/songxi/04-core-tab-ui/core_tab_ui/tab-profile.png`
- Create: `App/output/brand-ip/songxi/04-core-tab-ui/core_tab_ui/qa-report.md`

**Interfaces:**
- Consumes: approved Direction 01 image, character anchor, PRD IA.
- Produces: immutable four-image root-tab reference set for prototype and Flutter phases.

- [ ] Copy the approved Tonight PNG byte-for-byte into `tab-tonight.png` and compare SHA-256 values.
- [ ] Generate Sounds, Sleep, and Profile pages using the same canvas, palette, material, spacing, and bottom navigation contract.
- [ ] Inspect every generated image at original resolution and correct tab labels, order, or off-scope content.
- [ ] Record dimensions, hashes, requirement mapping, and visual checks in `qa-report.md`.

### Task 2: Add the reusable Brand IP skill supplement

**Files:**
- Create: `02_IP/APP品牌IP生成/references/core_tab_ui/core-tab-ui-expansion.md`
- Modify: `02_IP/APP品牌IP生成/SKILL.md`
- Modify: `00_Orchestrator/app-workflow/SKILL.md`

**Interfaces:**
- Consumes: the visual contract and observed baseline skill gap.
- Produces: a repeatable selected-home-to-all-root-tabs procedure and gate.

- [ ] Capture a read-only RED baseline showing the current skill does not force exact tab-shell invariants.
- [ ] Write the smallest reusable rule set: selection lock, PRD mapping, root-page generation, shell comparison, and handoff fields.
- [ ] Link the supplement from Brand IP Step 6 and require it from app-workflow Phase 2 before Phase 3.
- [ ] Re-run the same scenario and verify the amended skill explicitly preserves all invariants.

### Task 3: Build the Phase 3 product documents

**Files:**
- Create: `App/docs/prototype/00-需求追溯矩阵.md`
- Create: `App/docs/prototype/01-低保真原型说明.md`
- Create: `App/docs/prototype/02-交互说明文档.md`
- Create: `App/docs/prototype/03-页面跳转逻辑图.md`
- Create: `App/docs/prototype/04-原型评审清单.md`

**Interfaces:**
- Consumes: PRD P0 requirements and four-tab reference set.
- Produces: complete page/state coverage and acceptance evidence.

- [ ] Map every P0 requirement to at least one screen and interaction.
- [ ] Define loading, empty, error, permission-denied, and interruption-recovery states for every MVP page.
- [ ] Define all root-tab and detail-page transitions, including back behavior and degraded offline paths.
- [ ] Fill the review checklist with evidence and leave unavailable CDB/Figma-only checks explicitly pending.

### Task 4: Implement and verify the local clickable prototype

**Files:**
- Create: `App/docs/prototype/cdb/index.html`
- Create: `App/docs/prototype/cdb/styles.css`
- Create: `App/docs/prototype/cdb/app.js`
- Create: `App/docs/prototype/cdb/README.md`

**Interfaces:**
- Consumes: traceability matrix, interaction specification, root-tab visual contract.
- Produces: a dependency-light local prototype with stable editable-node IDs.

- [ ] Create a semantic single-root application shell and stable `data-codex-id` attributes.
- [ ] Implement four locked root tabs and MVP detail states without `innerHTML`.
- [ ] Add keyboard-visible controls, reduced-motion handling, 44pt-equivalent targets, and responsive phone framing.
- [ ] Run structural checks for one root, duplicate IDs, prohibited `innerHTML`, missing routes, and broken local assets.
- [ ] Open the prototype locally, traverse the MVP loop, and capture verification evidence.

### Task 5: Update handoff and run gates

**Files:**
- Modify: `App/docs/workflow/songxi/handoff-manifest.json`
- Recreate: `App/output/songxi-app-brand-ip.zip`

**Interfaces:**
- Consumes: verified Brand IP assets and Phase 3 package.
- Produces: workflow state ready for the next phase, or an explicit pending external-tool gate.

- [ ] Change selected tab direction/reference to Direction 01 and add `core_tab_ui_dir`.
- [ ] Rebuild the Brand IP ZIP and test the archive.
- [ ] Run `python3 03_UI_UX/creating-app-prototypes/scripts/validate_prototype_package.py App`.
- [ ] Set `gates.prototype` to PASS only if all mandatory checks, including available CDB/Figma checks, pass; otherwise retain PENDING with an explicit reason.

