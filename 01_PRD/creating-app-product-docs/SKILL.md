---
name: creating-app-product-docs
description: Use when a user provides competitor apps, websites, app-store links, or a product idea and wants an app feature list, product requirements document/PRD, product plan, or MVP scope.
---

# Creating App Product Docs

## Core principle

Research before inventing. Preserve the competitor's verified core-function baseline, separate the user's differentiation, design the complete product blueprint, then derive an MVP around one testable end-to-end value loop.

## Start

1. Inspect the workspace and preserve existing files.
2. Parse competitor names/links, the user's idea, explicit constraints, and requested mode.
3. If no mode is specified, ask the user to choose:
   - **智能模式**：快速产出，最多询问三个 scope-changing questions.
   - **深度访谈模式**：逐项确认后产出，每次只问一个问题.
4. Read [references/research-and-safety.md](references/research-and-safety.md) before researching competitors or any regulated/high-risk feature.

When mode is absent, use exactly these user-facing names and choices: `A. 智能模式（快速产出，最多三个关键问题）` and `C. 深度访谈模式（逐项确认后产出）`. Do not rename them to 快速模式、调研模式 or other labels. Never silently choose a mode. Preserve confirmed information when switching from 智能模式 to 深度访谈模式.

## 智能模式

Research first. Ask only questions whose answers materially change target users, platforms/devices, regulated intent, core differentiation, or MVP success. Ask at most three questions total; infer the rest conservatively and record every inference in assumptions.md.

After those answers—or immediately when the brief is sufficient—generate the complete deliverable set in one working turn.

Before expanding research, create the non-overwriting output directory and instantiate all five template files. Populate them progressively so a long research pass cannot end with zero artifacts.

## 深度访谈模式

Research the competitor baseline, then confirm target users, platforms/devices, differentiation, business model, and success metric one question at a time. Present 2–3 product routes with trade-offs and a recommendation. Confirm, in order:

1. positioning and core journey;
2. complete feature architecture and version layers;
3. data, platform feasibility, failure handling, and compliance;
4. business model, growth, testing, and release gates.

Generate files only after the user confirms the overall design. Do not repeat already confirmed questions.

## Shared workflow

1. Select a filesystem-safe product name. When file generation is authorized, create `docs/product/YYYY-MM-DD-产品名/`; if it exists, use a non-overwriting numeric suffix. Instantiate every template in `assets/` before drafting prose.
2. Prefer official competitor sites, app stores, platform documentation, regulators, and primary research. Record direct URLs and access dates.
3. In 智能模式, use at most two research batches. Target 4–8 essential sources and never exceed 12 without user approval: competitor official/app-store sources first, then one authoritative source per material platform or high-risk boundary.
4. Classify every material item as verified competitor baseline, competitor self-claim, user differentiation, public foundation, skill inference, or R&D.
5. Stop research when sources support the core baseline, platform boundaries, and high-risk decisions. Mark gaps instead of browsing indefinitely or guessing.
6. Replace all template tokens and keep these metadata lines exactly identical across the three main documents: 产品名、模式、平台、目标用户、商业策略.
7. Write a complete long-term blueprint before selecting MVP. Keep P0/MVP, P1, P2, R&D, and explicit exclusions consistent across files.
8. Keep the first draft reviewable: roughly 60–140 lines for the feature list, 180–380 for PRD, 100–240 for MVP, and 20–100 each for sources and assumptions. Put evidence detail in sources.md instead of bloating PRD.
9. Run:

   `python3 <skill-dir>/scripts/validate_product_docs.py <output-dir>`

10. Fix every reported issue and rerun until it prints PASS. Never claim completion after a failed validation.

## Required output

| File | Contract |
|---|---|
| `01-功能清单.md` | Competitor baseline, user differentiation, foundations/compliance, priorities, phases, acceptance summaries, exclusions/R&D |
| `02-PRD.md` | Positioning, users/JTBD, goals, metrics, IA, flows, detailed requirements, rules, data/privacy, failures, NFRs, business/growth, analytics, testing, risks, roadmap, decisions |
| `03-MVP范围.md` | Testable hypothesis, user loop, In/Out, minimum content/data/pages, acceptance, work packages, rollout, expansion, veto conditions |
| `sources.md` | Title, direct URL, source type, access date, supported claim, unverified gaps |
| `assumptions.md` | User-provided facts, source-confirmed facts, skill inferences, impact, reversibility, validation plan |

For health, medical, finance, minors, biometrics, recordings, or precise location, use current official sources and put unsupported claims behind an evidence/compliance/compatibility release gate or remove them from MVP.

## Quick reference

| Situation | Action |
|---|---|
| Competitor page is unavailable | Find an official alternative; mark unresolved gaps |
| Same-name competitor is ambiguous | Ask one identification question |
| Platform behavior differs | Specify per-platform implementation and fallback |
| User says “make one like this” | Preserve verified main modules in the blueprint; do not copy protected assets |
| High-risk sensor/AI claim lacks evidence | Move to R&D/Out of Scope with a release gate |
| Existing output directory | Add a numeric suffix; never overwrite silently |
| Browsing is unavailable | Use supplied materials, disclose staleness, and record missing sources |

## Example

User: “智能模式。参考 Tide，我想加入睡前心率和呼吸辅助，输出功能清单、PRD、MVP。”

Apply the competitor baseline, investigate phone/wearable boundaries, record health assumptions and official platform rules, keep Tide-like full modules in the long-term blueprint, derive a sleep-loop MVP, generate five files, and validate them.

## Common mistakes

- Producing one chat summary instead of five files.
- Listing generic features without verifying the competitor's current main modules.
- Treating competitor marketing claims as independently verified facts.
- Adding Web, wearables, enterprise, children, or subscriptions without recording an assumption.
- Calling a reduced feature list an MVP without a hypothesis and value loop.
- Claiming cross-platform parity without platform-specific feasibility.
- Copying competitor branding, UI, text, audio, stories, or visual assets.
- Leaving template tokens, TODO/TBD, contradictions, or unsupported medical claims.

## Final response

Lead with completion. Link all five files, summarize the product route and MVP loop, list material assumptions/risks, report validator PASS, and invite review. Do not imply that product, legal, medical, or technical claims are independently validated beyond the cited evidence.
