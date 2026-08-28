# Image production system

Use the built-in `image_gen` route and follow the installed `imagegen` skill. Use one call per distinct asset. For 2+ uncached images, follow the available creative-production batching rules; never substitute one collage for separately requested assets.

## Canonical character lock

After selecting the IP, write a compact character lock containing: species, silhouette, head/body ratio, ears, eyes, snout, limbs, signature mark, prop, exact palette, materials, default expression, and forbidden drift. Generate the canonical base image first. Every later prompt must reference that image and repeat immutable features. Do not derive from a drifted intermediate.

## Default image set

1. Six 16:9 concept sheets. Each is a distinct material/proportion direction with left-side front-standing 3D render and right-side matching 2D vector-style depiction. No text.
2. One square App Icon master. Use a close silhouette, no wordmark, no external rounded-square mask, and verify readability at small size.
3. One 9:16 launch artwork. Include exact App name and one short slogan only when requested. Verify spelling visually. For production implementation, prefer deterministic native text over baked text.
4. One 3:4, 3×5 expression sheet with exactly 15 cells: loading, refresh, sort, scroll, tap, delete, paste, like, favorite, share, follow, upload, download, submit, cancel. No captions.
5. Three 16:9 core Tab skeleton UI directions at 3840×2160: a light brand-led dashboard, a dark immersive direction, and a modular implementation-oriented direction. Use only navigation and features found in the PRD. Show the selected Tab state, main action, key status, and a restrained mascot presence.

If the PRD identifies a more important core Tab than Focus, use that Tab. Generate additional screens only when the PRD or user asks.

## UI physical language

Translate character design into UI tokens rather than pasting the mascot everywhere:

- palette → background, surfaces, actions, states;
- silhouette → corner radii and container geometry;
- material → matte, flocked, vinyl, glass, paper, or metallic surface treatment;
- signature mark/prop → progress, selection, and status motifs;
- personality → motion amplitude, copy tone, density, and feedback;
- safety/readability → contrast, type hierarchy, touch targets, and non-color state cues.

Keep screens buildable. Avoid device frames, decorative controls, fake features, illegible text, or poster-like composition.

## Prompt invariants

Every prompt must state use case, asset type, character reference role, subject, composition, medium, palette, material, lighting, exact text if any, immutable features, constraints, and avoid list. Never mention an existing commercial IP as a style target.

## Validation and retries

Inspect every output. Check count, ratio, role placement, character identity, complete limbs, spelling, UI structure, watermark absence, and requested feature presence. Retry only failed assets, with one targeted correction; allow at most two total attempts per asset. Preserve successful files. Upscaling does not create native 4K detail—label resampled outputs honestly.
