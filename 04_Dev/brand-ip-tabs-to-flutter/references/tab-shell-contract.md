# Tab shell contract

- One shared bottom navigation shell for all root Tabs.
- Root order and labels must match style-lock / PRD (e.g. 今日 → 应用 → 我的).
- Only active icon, label, and indicator change; inactive stays muted.
- Rebuild layout with Flutter widgets; reference PNGs are visual contracts only.
- When `core_tab_ui_status` is `PASS_WITH_RASTER_LIMITATION`, never ship baked raster text as the primary UI.
- Intervention / paywall / disclaimer are routes, not extra root Tabs, unless PRD says otherwise.
- Color tokens should follow style-lock when present (example Refocus: mist `#405D6A`, teal `#4E918B`, mineral `#F0EEE8`).
