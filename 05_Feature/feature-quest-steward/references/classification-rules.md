# Classification rules

Quest Steward uses a **waterfall**. First match wins. Always emit a one-line `reason`.

## Inputs

| Field | Meaning |
|-------|---------|
| `track_override` | Optional `main` \| `side` from human |
| `override_reason` | Required when override differs from auto result |
| `fxx` | List of PRD IDs (`F01`, …) |
| `priority` | `P0` \| `P1` \| `P2` \| `unknown` |
| `mvp_loop` | bool — on the open → intervene → continue/abandon → stats path |
| `infra` | bool — OS intercept, store billing, real permission path |
| `deferred_tab` | bool — explicitly deferred root Tab / P1–P2 surface |

## Waterfall

1. **Human override** — if `track_override` set → use it; log override.
2. **MVP loop P0** — any `fxx` + (`mvp_loop` or priority `P0` with loop keywords in title/summary: 打开/拦截/干预/呼吸/意图/继续/放弃/统计/今日) → `main`.
3. **P0 infra** — `priority=P0` and `infra=true` (or title contains 拦截/Screen Time/Shortcuts/StoreKit/订阅真/权限真机) → `main`, `kind=infra`.
4. **Side** — `priority` in `P1|P2` or `deferred_tab` or purely motion/polish without loop → `side`.
5. **Triage** — empty `fxx` and not infra and priority unknown → `needs_triage`.

## Dispatch implications

- `main` / `side` → `status=queued`
- `needs_triage` → `status=needs_triage` (never auto-started)
- Starting work: only `queued` + preferred `main` unless `force_side`

## Keywords (non-exhaustive, Chinese/English)

**Loop:** 打开, 拦截, 微干预, 呼吸, 意图, 继续, 放弃, 统计, 今日, intervene, breathe, intent, abandon  
**Infra:** 系统拦截, Screen Time, Shortcuts, StoreKit, Play Billing, 恢复购买, 权限, HealthKit  
**Side signals:** 动效, 高级交互, 生理触发, 网站拦截, 习惯提醒, 再次干预, polish, animation only
