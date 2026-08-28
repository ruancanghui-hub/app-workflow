# Reference-guided core Tab skeleton UI

Use this path when the user dislikes text-only skeleton directions or supplies competitor / inspiration screenshots. Every reference-guided Tab follows a **fixed two-step pipeline**:

1. **Step A — JSON profile:** extract design-system structure from the reference screenshot (no content/data).
2. **Step B — image2:** generate the skeleton using the reference image + JSON profile + character anchor.

Prefer **image-to-image (image2)** over pure text-to-image for core Tab skeletons.

## When to use

- User attaches 1+ mobile UI screenshots and asks to **参照 / 仿照 / match layout / like this**.
- User says skeleton pages from the default workflow feel generic or off-brand.
- PRD defines multiple core Tabs (e.g. Home, Sleep, Meditation, Sound) and user provides one reference per Tab or one app-wide style reference.

If no references are provided, keep the default three text-only directions in [image-production.md](image-production.md).

## Reference intake

1. **Ask once** if the user has reference screenshots. If they attach images in chat, treat those as authoritative layout/style inputs.
2. Save copies under `output/brand-ip/<slug>/04-core-tab-ui/references/` with stable names:
   - `ref-home.png`, `ref-sleep.png`, `ref-meditation.png`, `ref-sound.png`, or `ref-tab-<name>.png`
3. Write `04-core-tab-ui/ui-reference-notes.md` with Tab mapping, PRD alignment, and brand substitution plan before any generation.

## Tab mapping

Map references to PRD navigation, not to competitor product names.

| User reference likely shows | Map to PRD Tab | Reference file | JSON profile | Output |
|---|---|---|---|---|
| greeting + day strip + recommendation cards | Home / 首页 | `ref-home.png` | `design-system-profile-home.json` | `skeleton-home.png` |
| sleep stories, night hero, sleep chips | Sleep / 睡眠 | `ref-sleep.png` | `design-system-profile-sleep.json` | `skeleton-sleep.png` |
| meditation categories, quote hero | Meditation / 冥想 | `ref-meditation.png` | `design-system-profile-meditation.json` | `skeleton-meditation.png` |
| soundscapes, mix chips, play hero | Sound / 声音 | `ref-sound.png` | `design-system-profile-sound.json` | `skeleton-sound.png` |
| other PRD Tab | `<tab-slug>` | `ref-tab-<tab-slug>.png` | `design-system-profile-<tab-slug>.json` | `skeleton-<tab-slug>.png` |

Generate **one skeleton per core Tab** named in the PRD. Skip Tabs with no reference unless the user asks for a text-only fallback.

---

## Step A — Extract JSON design-system profile

Run this **before** image2 for each reference screenshot. Use a vision-capable model turn with the saved reference image attached.

### Extraction prompt (use verbatim)

```
Create a JSON-formatted design system profile. This profile should extract relevant visual design information from the provided screenshots. The JSON output must specifically include:

The overarching design style (e.g., color palette, typography, spacing, visual hierarchy).

The structural elements and layout principles.

Any other attributes crucial for an AI to consistently replicate these design systems.

Crucially, do not include the specific content or data present within the images, focusing solely on the design system itself.
```

### Rules for Step A

- Output **valid JSON only** — no markdown fences, no commentary.
- Extract **design system attributes**, never screenshot content:
  - ✅ color roles, type scale, spacing rhythm, corner radius, elevation, blur/glass treatment, component types, grid structure, nav pattern, visual hierarchy
  - ❌ quotes, article titles, product names, user names, logos, slogans, category labels, numbers, dates, or any text/copy from the image
- Save to `04-core-tab-ui/design-system-profile-<tab>.json`.
- If multiple references share one app-wide style, still produce **one JSON per Tab**; factor shared tokens into each file and note shared vs Tab-specific keys in `ui-reference-notes.md`.

### Recommended JSON shape

Adapt keys to what the screenshot actually shows; keep the schema consistent across Tabs:

```json
{
  "meta": {
    "tab": "meditation",
    "reference_file": "ref-meditation.png",
    "extracted_at": "ISO-8601",
    "content_excluded": true
  },
  "design_style": {
    "mood": "calm, airy, minimalist",
    "color_palette": {
      "background": "soft gradient, high-key",
      "surface": "translucent white with blur",
      "text_primary": "dark grey",
      "text_secondary": "muted grey",
      "accent": "warm gold for active state"
    },
    "typography": {
      "header_scale": "large bold title",
      "body_scale": "regular subtext",
      "hierarchy": "title > section header > card label > metadata"
    },
    "spacing": {
      "page_padding": "generous horizontal inset",
      "section_gap": "large vertical rhythm",
      "card_gap": "consistent grid gutter"
    },
    "effects": {
      "corner_radius": "16-24px on cards and buttons",
      "glassmorphism": "header controls use translucent circular buttons",
      "imagery": "soft-focus photography, low contrast, high-key"
    }
  },
  "structure": {
    "layout_type": "vertical scroll",
    "regions": [
      { "name": "header", "position": "top", "elements": ["page title", "search", "membership chip"] },
      { "name": "hero", "position": "upper", "elements": ["centered quote block", "avatar circle"] },
      { "name": "content", "position": "middle", "elements": ["section title", "two-column card grid"] },
      { "name": "bottom_nav", "position": "fixed bottom", "elements": ["4 tabs", "icon + label", "active state highlight"] }
    ],
    "layout_principles": [
      "card-on-background with image fills",
      "text overlaid bottom-left on cards",
      "bottom nav mirrors 4-tab product structure"
    ]
  },
  "components": {
    "cards": { "type": "image background", "columns": 2, "aspect": "portrait-ish rectangle" },
    "chips": null,
    "carousel": null,
    "play_cta": null
  },
  "replication_notes": [
    "Preserve region order and component types",
    "Do not reproduce screenshot text or branding",
    "Active tab uses accent color on icon and label"
  ]
}
```

Validate JSON parses before proceeding to Step B.

---

## Step B — image2 generation

Read the installed `imagegen` skill. For each Tab, call **image-to-image** with:

| Input | Role |
|---|---|
| Reference screenshot (`ref-<tab>.png`) | Structural and compositional guide |
| `design-system-profile-<tab>.json` | Style and layout contract (embedded in prompt) |
| Character anchor | Brand palette, mascot restraint, materials |

### image2 prompt template

Build one prompt per Tab:

```
Mobile app UI skeleton screen for <Tab>, 16:9, buildable layout.

DESIGN SYSTEM (from JSON — layout/style only, no copied content):
<paste or summarize design-system-profile-<tab>.json>

BRAND OVERLAY:
- Character lock palette, materials, and restrained mascot from anchor
- PRD-appropriate short copy in <locale>; do not reuse reference screenshot text
- Active bottom-nav item: <Tab>

REFERENCE ROLE (image2 input):
- Preserve layout hierarchy, spacing rhythm, region order, component types, and nav structure from the attached reference image
- Do not clone competitor branding, logos, characters, or slogans

CONSTRAINTS:
- No device frame, no fake features outside PRD, legible hierarchy
- Apply brand IP colors and surfaces over the reference structure

AVOID:
- Competitor logo, trademarked mascot, copied slogans, poster composition, illegible microtext, content/data from the reference image
```

### image2 execution rules

1. Attach the **same reference image** used in Step A as the image2 source.
2. Include the JSON profile in the text prompt — do not rely on the image alone.
3. Also pass the **character anchor** as a style reference when the tool supports multiple inputs.
4. Strength: favor layout fidelity over pixel copy; start moderate so brand palette and mascot can land.
5. Target `3840×2160` (16:9); disclose if resampled.
6. Retry only failed Tabs with one targeted correction (max two attempts per asset).

Do **not** generate core Tab skeletons from text alone when a reference exists for that Tab.
Do **not** skip Step A — the JSON profile is a required intermediate artifact.

---

## Brand adaptation rules

References inform **composition**, not **identity**. The JSON profile captures structure; brand IP fills content.

| From JSON / reference structure | Into brand IP |
|---|---|
| header + search + membership chip pattern | same structure, brand colors and icon style |
| hero quote / carousel / play CTA region | same hierarchy, PRD-appropriate copy and imagery mood |
| chip row or category grid | same component pattern, PRD categories and brand photography |
| bottom nav 4-item pattern | same item count/order as PRD, brand active-state color |
| glass / blur cards | translate to character material language (matte, paper, vinyl, glass) |

Never reproduce a known commercial app's logo, character, exact Chinese/English slogans, or distinctive trademarked illustration. Abstract the pattern; apply the selected IP.

---

## Output set with references

When references are provided, deliver:

- `04-core-tab-ui/references/*` — saved input screenshots
- `04-core-tab-ui/ui-reference-notes.md` — Tab mapping, brand substitution, shared tokens
- `04-core-tab-ui/design-system-profile-<tab>.json` — one per referenced Tab (Step A)
- `04-core-tab-ui/skeleton-<tab>.png` — one 16:9 image per core Tab (Step B)
- optional `04-core-tab-ui/contact-sheet.png` — only if user asks; never substitute for per-Tab files

Skip the default three generic directions (light / dark / modular) when reference-guided Tabs fully cover the PRD navigation. If references cover only some Tabs, use the two-step pipeline for referenced Tabs and text-only for the remainder — state the split in `ui-reference-notes.md`.

---

## Codex usage

In Codex, the user may attach screenshots directly in the thread. On the first turn:

1. Acknowledge attached images and map each to a PRD Tab.
2. Confirm missing Tabs or ambiguous mappings in **one** short question; if the user requested a fully automatic run, state assumptions and continue.
3. Persist attachments to `04-core-tab-ui/references/` before Step A.
4. Run Step A (JSON extraction) for each reference, save JSON files, then run Step B (image2) per Tab.

---

## Validation

### Step A (JSON)

- Valid JSON, parses without error
- Contains design style, structure, and replication attributes
- **No** screenshot-specific content: no quotes, titles, labels, numbers, logos, or competitor names from the image
- `content_excluded: true` in `meta` (or equivalent confirmation)

### Step B (image2)

- Layout matches the JSON `structure` and reference information architecture, not its branding
- Active bottom-nav item matches the screen
- PRD features only; no invented tabs or controls
- Mascot presence is restrained and consistent with character lock
- Palette and surfaces reflect brand IP, not the reference app's colors
- Text is short, legible, and in PRD language
- No watermarks, competitor marks, or copied slogans

Record per asset in `qa-report.md`: reference used, JSON profile path, image2 prompt summary, retries, and resampling.
