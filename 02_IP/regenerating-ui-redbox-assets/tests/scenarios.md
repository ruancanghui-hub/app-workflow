# Skill scenarios

## Scenario 1 — annotated UI, icons only
User uploads a screenshot with red boxes around search, Plus, status emoji, four feature art tiles and five tab icons, asking for separate code-ready images and a zip.

Expected: inventory every marked asset; regenerate each separately; transparent PNG for glyph icons; no red boxes; semantic English filenames; grouped zip.

## Scenario 2 — annotated UI + background
User asks for all red-box items **and** the page background.

Expected: additionally regenerate a clean full-screen background with no UI/text. Put it under `backgrounds/`.

## Scenario 3 — batch limit
Image generation cannot produce every asset in one call.

Expected: split into batches, preserve style consistency, and create the final combined zip only after all batches are complete.

## Scenario 4 — literal crop request
User explicitly says “不要重画，只要原图切出来”.

Expected: do not apply regeneration workflow; crop/export instead.
