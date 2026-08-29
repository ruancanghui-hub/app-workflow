---
name: composing-asset-ui-prototype
description: >
  Compose a 1:1 clickable HTML prototype from 05-ui-assets PNG packages against 04-core-tab-ui
  visual contracts. Phase 2b→3 bridge: verify cut assets align with locked Tab UI before full
  Phase 3 interaction docs or Flutter build.

  Use this skill whenever the user:
  - Has finished 05-ui-assets packaging and wants 资产合成原型 or 06_asset_ui
  - Says 1:1 原型、叠对照验收、用切图拼页面、asset UI prototype
  - Wants to verify red-box assets before creating-app-prototypes or Flutter scaffold
  - Mentions building HTML from manifest.json + core Tab reference images

  Do NOT use for full interaction specs, traceability matrices, or CDB/Figma export —
  those belong to creating-app-prototypes (Phase 3).
---

# Composing Asset UI Prototype

> **Language**: Respond in the same language the user uses.

Turn per-Tab `05-ui-assets/` into a **1:1 asset-composite prototype** under `06_asset_ui/`.
The visual contract in `04-core-tab-ui/` is the acceptance baseline.

**Scope (locked decisions):**

| Decision | Choice |
| --- | --- |
| Fidelity target | 叠对照验收 — backgrounds, icons, text positions align; CSS glass/waveform are approximations |
| Text strategy | HTML text for all labels; PNG only for icons and backgrounds |
| Skill location | Project-level only (`03_UI_UX/`), referenced by orchestrator |
| Pipeline role | 2b→3 bridge — asset verification only; full interaction docs stay in Phase 3 |

**Upstream:** `regenerating-ui-redbox-assets` (Phase 2b)  
**Downstream:** `creating-app-prototypes` (Phase 3), Flutter scaffold

---

## Phase 0: Material Discovery & Analysis

Before writing HTML, understand every input.

### 0a. Locate all inputs

```text
output/brand-ip/<slug>/
├── 04-core-tab-ui/          ← visual contract (whole-page PNG, QA PASS)
├── 05-ui-assets/<tab>/      ← decomposed PNG + manifest.json per Tab
├── 05-prompts/              ← copy / Tab descriptions (optional)
├── asset-manifest.csv       ← dimensions & hashes (optional)
├── qa-report.md             ← PASS status per Tab
└── CONTEXT.md               ← domain glossary (create if missing)
```

Adapt paths if the slug differs. Read `qa-report.md` and every `manifest.json`.

### 0b. Deep visual-contract analysis

For **every** reference PNG in `04-core-tab-ui/`:

1. **Read each image** with the Read tool — examine layout directly.
2. For each image, document in `06_asset_ui/visual-analysis.md`:
   - **Page identity**: which root Tab
   - **Layout structure**: header, main content, footer/nav
   - **Component inventory**: buttons, cards, nav elements with pixel boxes
   - **Content inventory**: all visible Chinese copy
   - **Color extraction**: hex values for text, glass, accents
   - **Typography**: font sizes and weights per element
   - **Interaction states**: active Tab, selected items
   - **Data patterns**: seed-data shapes for Phase 3
3. Build a **page map** (Mermaid) showing root Tab navigation flow.

Use measured coordinates from this analysis to populate `layout-spec.json`. Do not guess from percentages.

### 0c. Asset inventory cross-check

For each Tab folder under `05-ui-assets/<tab>/`:

| Group | Expected roles |
| --- | --- |
| `backgrounds/` | Page (and card) backgrounds per contract |
| `feature_art/` | Card icons, section decorations |
| `nav_icons/` | All four root Tab icons **for this page's active state** |
| `status/` | `profile_orb`, indicators, badges |
| `ui_controls/` | Search, play, add, mute, grid, etc. |

Stop if any contract-visible element lacks a manifest entry or file on disk.

---

## Phase 1: Layout Spec & Domain Docs

Produce `06_asset_ui/layout-spec.json` — the coordinate contract for implementation.

### 1a. Design coordinate system

- Fixed canvas: **941 × 1672** (read actual from reference PNG if different).
- Record every element box as `{ x, y, w, h }` in design pixels.
- Map each box to either a `manifest.json` `source_role` or an HTML text node id.

Use [references/layout-spec-template.json](references/layout-spec-template.json) as starting structure.

### 1b. Layering order (bottom → top)

1. `backgrounds/*` — full-bleed `<img class="bg">`
2. Glass containers — **CSS only** (never bake into PNG)
3. `feature_art/`, `status/`, `ui_controls/` — positioned `<img>`
4. **HTML text** — titles, subtitles, card labels, tags (never crop text from reference)
5. `nav_icons/` — bottom tab bar from **current Tab's** asset folder
6. Reference overlay — hidden until QA toggle enabled

### 1c. Root Tab contract

Order is fixed: `首页 → 睡眠 → 冥想 → 声音`.

Only the active Tab highlight changes between root pages. No IA changes.

### 1d. Domain glossary

Update `output/brand-ip/<slug>/CONTEXT.md` with resolved terms. See [references/context-terms.md](references/context-terms.md).

Offer ADR at `docs/adr/0001-html-asset-composite-prototype.md` when documenting HTML composite vs Figma-only review.

---

## Phase 2: HTML Structure

Create `06_asset_ui/index.html`.

### 2a. Shell rules

- Phone frame is a fixed **941×1672** canvas scaled via `--phone-scale` (set in `app.js` on resize).
- All element positions use **absolute px** from `layout-spec.json` / `visual-analysis.md` — no `clamp()` or percentage guessing.
- Exactly one `data-codex-root` on `<main>`.
- Every mapped node: unique stable `data-codex-id`.
- Do **not** use `innerHTML` in JavaScript.
- Asset paths: relative `../05-ui-assets/<tab>/<group>/<file>`.
- Each Tab: `[data-screen="<tab>"]`; only one visible at a time.

### 2b. Per-screen structure

For each root Tab, build:

```html
<div class="screen" data-screen="<tab>">
  <img class="bg" src="../05-ui-assets/<tab>/backgrounds/..." alt="">
  <img class="compare" src="../04-core-tab-ui/<tab>-tab-*.png" alt="" hidden>  <!-- QA overlay -->
  <!-- header: HTML text + ui_controls/status assets -->
  <!-- content: glass sections + feature_art + HTML labels -->
  <nav class="tabbar">...</nav>  <!-- this tab's nav_icons/ -->
</div>
```

### 2c. Copy reference PNGs

Reference overlay paths point to `../04-core-tab-ui/<tab>-tab-*.png` — do **not** copy duplicates into `06_asset_ui/`.

---

## Phase 3: CSS Composition

Create `06_asset_ui/styles.css`.

### 3a. Frame scaling

```css
.stage { aspect-ratio: 941 / 1672; /* scale to viewport */ }
```

Phone frame scales proportionally; internal layout uses percentages derived from `layout-spec.json`.

### 3b. Glass containers

```css
backdrop-filter: blur(22px) saturate(140%);
```

Approximate frosted panels in CSS. Document known deviation from reference in README.

### 3c. Theme per Tab

| Tabs | Text | Glass | Active nav |
| --- | --- | --- | --- |
| home, sleep, sound | light on dark | dark glass | white highlight |
| meditation | dark on light | light glass | `#e6a23c` accent |

### 3d. Icon sizing

`object-fit: contain` for all PNG assets. Size from layout-spec percentages, not raw export dimensions (many icons export at 1254×1254).

### 3e. Motion

Respect `prefers-reduced-motion` for decorative animations (waveform, fade).

---

## Phase 4: Tab Navigation & QA Toolbar

Create `06_asset_ui/app.js`.

### 4a. Tab switching

- Buttons: `data-tab="<tab>"` → show matching `[data-screen]`, toggle `.is-active` on nav only.
- No route changes, no `innerHTML`.

### 4b. Reference overlay toolbar

Ship a fixed review toolbar:

| Control | Behavior |
| --- | --- |
| Checkbox「对照参考图」 | Show/hide `.compare` on active screen |
| Opacity slider (default 40%) | Blend reference over composite |

This is the primary 1:1 acceptance tool for this skill.

---

## Phase 5: Visual Verification Loop

**Repeat for every Tab.** Prototypes are truth for layout; assets must match.

### 5a. Open prototype locally

```bash
open output/brand-ip/<slug>/06_asset_ui/index.html
# or: python3 -m http.server 8765  (from slug parent if needed)
```

### 5b. Overlay comparison

For each Tab:

1. Switch to the Tab screen.
2. Enable reference overlay at ~40% opacity.
3. Compare systematically:
   - **Background**: scene alignment and crop
   - **Icons**: position and scale vs contract
   - **Text**: label placement and hierarchy
   - **Nav bar**: four icons, correct active state, label order
   - **Glass panels**: acceptable CSS approximation (note deviations)

### 5c. Fix discrepancies

For each misalignment:

1. Adjust `layout-spec.json` coordinates.
2. Update CSS/HTML positioning.
3. Re-open and re-compare.

Max 3 iterations per Tab. Focus on backgrounds and icons first.

### 5d. Acceptance threshold

With overlay at ~40%:

- Backgrounds and icons align within **~2%** of reference edges.
- All text readable and in correct regions.
- No broken asset paths.
- Glass blur / waveform / tag pills may differ — document in README.

---

## Phase 6: Automated Validation

Run the package validator before claiming complete:

```bash
python3 03_UI_UX/composing-asset-ui-prototype/scripts/validate_asset_ui_prototype.py \
  output/brand-ip/<slug>
```

Checks: required files, one `data-codex-root`, unique `data-codex-id`, no `innerHTML`, asset path existence, four Tab screens.

---

## Phase 7: Handoff & Documentation

### 7a. README

Create `06_asset_ui/README.md`:

- How to open locally
- Overlay QA procedure
- Known CSS approximations
- Explicit note: **not** a Phase 3 deliverable — interaction specs come from `creating-app-prototypes`

### 7b. QA report update

Append a row to `qa-report.md` for `06_asset_ui/` PASS status per Tab.

### 7c. Handoff manifest

```json
"phases": {
  "brand": {
    "asset_ui_prototype_dir": "output/brand-ip/<slug>/06_asset_ui",
    "asset_ui_prototype_status": "PASS",
    "layout_spec": "output/brand-ip/<slug>/06_asset_ui/layout-spec.json"
  }
}
```

`asset_ui_prototype_status` values: `NOT_REQUESTED` | `IN_PROGRESS` | `PASS` | `FAIL`.

Does **not** block Phase 3 if `NOT_REQUESTED`. When `PASS`, Phase 3 may consume `layout-spec.json` coordinates.

---

## Deliverables Checklist

Before declaring done, verify every item:

- [ ] All four root Tabs render with local assets — no broken images
- [ ] Tab switch works; only one screen visible; only nav active state changes
- [ ] All visible text is HTML, not baked into PNGs
- [ ] Each Tab uses its own `nav_icons/` folder for active-state icons
- [ ] Reference overlay QA passes per Tab at ~40% opacity
- [ ] `layout-spec.json` matches implemented structure
- [ ] `CONTEXT.md` updated at slug root
- [ ] `validate_asset_ui_prototype.py` exits 0
- [ ] README documents known CSS approximations and Phase 3 boundary

---

## Critical Principles

1. **Visual contract is truth** — `04-core-tab-ui/` reference PNGs define layout; `05-ui-assets/` must reconstruct them.

2. **Text is HTML** — card labels, titles, tags are editable text layers for i18n and Flutter handoff. PNGs are icons and backgrounds only.

3. **Per-Tab nav assets** — never reuse `home/nav_icons/` on every screen; each Tab folder carries its own active-state set.

4. **Overlay, don't guess** — use the reference overlay toolbar for 1:1 acceptance; do not claim PASS without visual comparison.

5. **Bridge, not Phase 3** — this skill verifies asset fidelity and records coordinates. Interaction states, traceability, and CDB export belong to `creating-app-prototypes`.

6. **No crops as assets** — if `manifest.json` lists a role, use the regenerated PNG path, not a slice of the reference image.

---

## Reference implementation

`output/brand-ip/healing_tabs/06_asset_ui/` is the canonical example for four Tab healing-app layout.

## Additional resources

- Layout template: [references/layout-spec-template.json](references/layout-spec-template.json)
- Orchestrator position: [references/workflow-integration.md](references/workflow-integration.md)
- Domain terms: [references/context-terms.md](references/context-terms.md)
- Upstream assets: `02_IP/regenerating-ui-redbox-assets/SKILL.md`
- Full prototype phase: `03_UI_UX/creating-app-prototypes/SKILL.md`
