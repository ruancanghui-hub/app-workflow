# App-workflow integration

## Position

- **Phase 5a** — incremental Feature Quest loop under Phase 5.
- Does **not** set `gates.features = PASS` alone.
- Complements `implement-flutter-features` (whole-MVP trace) and uses `regenerating-ui-assets-to-flutter-page` at stage `page`.

## Prerequisites

- `gates.flutter_scaffold == PASS` (or Phase 4a TabShell app ready)
- Prefer `gates.prd == PASS` so `Fxx` mapping is stable

## Handoff

```json
"phases": {
  "features": {
    "quests_dir": "docs/workflow/<slug>/quests",
    "quests_backlog": "docs/workflow/<slug>/quests/backlog.json",
    "active_quest_id": null,
    "quests_steward_status": "ACTIVE"
  }
}
```

## Orchestrator triggers

| User intent | Action |
|-------------|--------|
| 加功能 / 新任务 / 主线支线 | `enqueue_quest.py` |
| 开始下一个主线 | `start_next_main.py` then Doc confirm |
| 切图成页 | only after `design` PASS → child skill `regenerating-ui-assets-to-flutter-page` |
| 整包 features gate | `implement-flutter-features` validator |

## After each quest `done`

1. Update `implementation-trace.md` rows for bound `Fxx`.
2. Update `.scratch/.../feature-checklist.md` if present.
3. Clear `active_quest_id` or point to next queued main.
4. Offer next main; do not silently start Side while Main remains.
