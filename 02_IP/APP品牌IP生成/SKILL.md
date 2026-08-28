---
name: generate-app-brand-ip
description: >-
  Use when a user provides an App PRD or product brief and wants a mascot-led brand IP, character concepts,
  App Icon, launch screen, expression/action system, branded core-tab UI concepts, or a packaged image delivery
  for a new mobile product. Also use when the user attaches competitor or inspiration screenshots and wants
  reference-guided core Tab skeleton UI: first extract a JSON design-system profile (layout/style only, no content),
  then generate via image-to-image (image2) in Codex or Cursor.
---

# Generate App Brand IP

Turn one PRD into a coherent mascot-led App brand system and reviewable image package. Base every decision on the product promise; keep one canonical character identity across all derivatives.

## Required companion skills

- **REQUIRED:** Use `imagegen` for all raster generation and editing.
- **REQUIRED:** Use `creative-production:produce` when its board and batching capabilities are available.
- Use product or platform UI skills only when implementing code; this Skill produces design artifacts by default.

## Workflow

1. Read the complete PRD and any linked authoritative product documents. Read [references/prd-and-strategy.md](references/prd-and-strategy.md).
2. Write a concise PRD brief and three complete IP strategy directions. Do not browse trends unless the user asks for current market evidence or the choice materially depends on current facts.
3. Ask the user to select one direction. If they requested a fully automatic run, select the highest-scoring direction, state the assumption, and continue without blocking.
4. Create the canonical character lock. Read [references/image-production.md](references/image-production.md) and [references/character-lock-invariant-corrections.md](references/character-lock-invariant-corrections.md) before generating any image. Convert countable and immutable features into an invariant matrix before the first image call.
5. Generate the canonical base concepts, inspect them, and select or obtain selection of the character anchor. Never generate downstream assets from text alone once an anchor exists.
6. **Core Tab skeleton UI** — before generating, check whether the user supplied reference screenshots (in chat or on disk).
   - **With references:** read [references/ui-reference-skeleton.md](references/ui-reference-skeleton.md). For each reference Tab, run the **two-step pipeline**: (A) extract a JSON design-system profile from the screenshot — layout/style only, no image content; (B) generate one skeleton via **image2** using the saved reference + JSON profile + character anchor. Save `design-system-profile-<tab>.json` before calling image2. Do not use text-only generation for a Tab that has a reference.
   - **Without references:** generate the App Icon, launch screen, 15-action sheet, and three text-only core-Tab UI directions from the same anchor per [references/image-production.md](references/image-production.md).
   - In both cases, keep exact copy short and verify it visually.
7. If step 6 used reference-guided skeletons, generate the App Icon, launch screen, and 15-action expression sheet from the same character anchor. (When step 6 followed the no-reference path, those assets are already included — skip duplicates.)
8. After the user approves one direction and requests the remaining root pages, read [references/core_tab_ui/core-tab-ui-expansion.md](references/core_tab_ui/core-tab-ui-expansion.md), freeze the approved page, map every PRD root Tab, and expand the selected system under `04-core-tab-ui/core_tab_ui/`.
9. Inspect every asset against the invariant matrix and retry only failures with one targeted edit. Preserve successful outputs, allow at most two total attempts per asset, and never silently substitute missing deliverables.
10. Read [references/delivery.md](references/delivery.md), create the delivery tree, prompts, QA report, and manifest, then run `scripts/pack_delivery.py` and verify the ZIP.
11. Deliver clickable absolute paths and summarize the recommended direction, reference mapping (if any), JSON profiles, image2 usage, actual dimensions, resampling, retries, and limitations.

## Scope rules

- Treat the uploaded PRD as authoritative. Do not add Android, web, store, social, merchandising, or marketing deliverables unless the PRD or user requests them.
- Default to the PRD's languages. For bilingual products, choose names and slogans that remain pronounceable and culturally legible in both languages.
- Never copy a currently popular character. Translate trends into abstract properties such as silhouette strength, emotional value, material contrast, collectibility, and motion potential.
- Reference screenshots may guide **layout and component patterns** only. Never copy competitor logos, characters, slogans, or distinctive trademarked art. See [references/ui-reference-skeleton.md](references/ui-reference-skeleton.md).
- Do not invent a logo vector, font license, trademark clearance, transparent source, editable 3D model, or native resolution that was not actually produced.
- Do not modify product code unless the user separately asks for implementation.

## Completion gate

Do not claim completion until all requested files exist, the image count is correct, visual inspection passes, and the ZIP test succeeds. When core Tab expansion is requested, completion also requires the selected source hash, actual canvas size, root-tab requirement map, `qa-report.md`, and an explicit raster-versus-editable shell result from the core Tab supplement. When reference-guided skeletons are used, completion also requires `design-system-profile-<tab>.json` per referenced Tab. A partial generation is a progress update, not a final delivery.
