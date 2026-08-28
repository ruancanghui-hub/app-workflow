# Delivery contract

Create this project-local structure, replacing `<slug>` with the product slug:

```text
output/brand-ip/<slug>/
├── 00-strategy/
│   ├── prd-brief.md
│   ├── three-ip-directions.md
│   └── character-lock.md
├── 01-character-concepts/
├── 02-app-branding/
│   ├── app-icon-master.png
│   └── launch-screen.png
├── 03-expressions/
├── 04-core-tab-ui/
│   ├── references/                        # user-supplied layout references
│   ├── ui-reference-notes.md              # Tab mapping + brand substitution
│   ├── design-system-profile-<tab>.json   # Step A: extracted design system (no content)
│   └── skeleton-<tab>.png                 # Step B: image2 outputs
├── 05-prompts/
├── qa-report.md
└── asset-manifest.csv
```

Use stable descriptive filenames. Save the final prompt set, selected assumptions, dimensions, generation route, retries, and known limitations. Never label raster artwork as SVG or editable vector. Do not promise native 4K/8K if the model returned a smaller image; either retain it as generated or resample and disclose that fact.

Run:

```bash
python3 scripts/pack_delivery.py output/brand-ip/<slug> output/<slug>-app-brand-ip.zip
```

Use the absolute script path resolved from this Skill directory. Confirm ZIP integrity and provide a clickable absolute file link. Also show a concise contact sheet or the most important outputs inline when the host supports local images.

## QA report checklist

- PRD features and non-goals respected
- three strategies are genuinely different
- selected character lock present
- six base concepts delivered
- icon has no baked wordmark
- launch copy matches exactly
- expression sheet has exactly 15 cells
- three UI directions match the product's real navigation **or** one reference-guided skeleton exists per PRD core Tab with `ui-reference-notes.md`, `design-system-profile-<tab>.json`, and saved references
- JSON profiles contain design style and structure only — no screenshot text, labels, logos, or content data
- reference-guided assets record Step A JSON path, image2 prompt, source reference, and brand substitutions in `qa-report.md`
- all final images exist and are non-empty
- dimensions and resampling disclosed
- no watermarks, third-party characters, or unsupported claims
- manifest and verified ZIP included
