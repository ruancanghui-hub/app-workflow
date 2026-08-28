---
name: generate-app-brand-ip
description: Use when a user provides an App PRD or product brief and wants a mascot-led brand IP, character concepts, App Icon, launch screen, expression/action system, branded core-tab UI concepts, or a packaged image delivery for a new mobile product.
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
4. Create the canonical character lock. Read [references/image-production.md](references/image-production.md) before generating any image.
5. Generate the canonical base concepts, inspect them, and select or obtain selection of the character anchor. Never generate downstream assets from text alone once an anchor exists.
6. Generate the App Icon, launch screen, 15-action sheet, and three core-Tab UI directions from the same anchor. Keep exact copy short and verify it visually.
7. Inspect every asset and retry only failures. Preserve successful outputs and never silently substitute missing deliverables.
8. Read [references/delivery.md](references/delivery.md), create the delivery tree, prompts, QA report, and manifest, then run `scripts/pack_delivery.py` and verify the ZIP.
9. Deliver clickable absolute paths and summarize the recommended direction, actual dimensions, resampling, retries, and limitations.

## Scope rules

- Treat the uploaded PRD as authoritative. Do not add Android, web, store, social, merchandising, or marketing deliverables unless the PRD or user requests them.
- Default to the PRD's languages. For bilingual products, choose names and slogans that remain pronounceable and culturally legible in both languages.
- Never copy a currently popular character. Translate trends into abstract properties such as silhouette strength, emotional value, material contrast, collectibility, and motion potential.
- Do not invent a logo vector, font license, trademark clearance, transparent source, editable 3D model, or native resolution that was not actually produced.
- Do not modify product code unless the user separately asks for implementation.

## Completion gate

Do not claim completion until all requested files exist, the image count is correct, visual inspection passes, and the ZIP test succeeds. A partial generation is a progress update, not a final delivery.
