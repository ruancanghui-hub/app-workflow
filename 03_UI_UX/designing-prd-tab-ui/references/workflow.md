# Root Tab workflow

## Function-design contract

Create one table row per P0 root Tab:

| Tab | P0 requirements | Primary action | Secondary entries | Required states | Deferred |
|---|---|---|---|---|---|

Use exact labels and ordering from the PRD. Distinguish a root screen from its detail, modal, onboarding, and full-screen intervention flows.

## Shared shell

Record the source image path, SHA-256, canvas size, palette, type hierarchy, safe-area treatment, card radius, bottom-navigation order, active/inactive states, mascot scale, and behavior of brand motifs. Root pages use the same shell; only active state and screen content vary.

## State coverage

For every function, place the user-facing recovery where it is needed:

- permission denied or revoked: show current impact and a route to system setup/help;
- empty list: explain the first action and offer it;
- free allowance reached: retain existing rules and route to subscription without silently adding an item;
- offline/local state: keep local statistics and rules usable, identify only actions that need network;
- subscription restore: make it reachable from settings;
- intervention: model it as a full-screen flow, outside root navigation.

## Handoff

When root-page expansion is requested, set `core_tab_ui_requested = true`; record the selected source, root expansion directory, style-lock path, and deferred roots in the handoff. Generated raster output is `PASS_WITH_RASTER_LIMITATION` until Phase 3 implements one editable shared navigation component.
