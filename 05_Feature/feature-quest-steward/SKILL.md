---
name: feature-quest-steward
description: >-
  功能任务管家：自动判别主线/支线并派发队列；每个任务固定走
  Doc → UI/交互规格 → regenerating-ui-assets-to-flutter-page。
  Use when adding features like game quests, main/side backlog, steward dispatch,
  or incremental Doc→Design→cut-assets→Flutter page loops after Tab shell exists.
---

# Feature Quest Steward（功能任务管家）

把「无限加功能」收成可重复的游戏任务循环：管家自动判别 **主线 / 支线**、写入队列；开工后严格 **文档 → 设计页元素与交互 → 切图落地 Flutter 页**。不取代 Phase 5 整包追溯；做完的任务回写 `implementation-trace`，由 `implement-flutter-features` 收口 `gates.features`。

## Prerequisites

- `gates.flutter_scaffold == "PASS"`（或已有可运行 Flutter 工程 + 根 Tab）
- 产品 `docs/workflow/<slug>/handoff-manifest.json` 存在
- PRD / 追溯矩阵可读（用于映射 `Fxx` 与 MVP 闭环）

## When to use

- 用户说要加功能、开主线/支线、像游戏一样做任务
- 用户调用 `/feature-quest-steward` 或「管家派发 / 开始下一个主线」
- 已有 Tab 骨架，需要按任务增量补流程与高保真页

## Core terms

| 术语 | 含义 |
|------|------|
| Feature Quest | 一条可验收的用户价值增量；绑定 ≥1 个 PRD `Fxx` |
| Main Quest | MVP 闭环上的 P0，或 P0 基建（真拦截 / 商店 / 权限真机） |
| Side Quest | P1/P2、延后 Tab、非闭环增强、纯动效打磨 |
| Quest Steward | 自动判别 + 入队派发；开工需确认；可人工覆盖 |

## Directory contract

```text
docs/workflow/<slug>/quests/
├── backlog.json              # 队列真源（机器）
├── BACKLOG.md                # 人读视图（脚本同步）
├── steward-log.md            # 每次判别 / 派发 / 覆盖记录
└── <quest_id>/               # 例 q-001-simulate-open
    ├── quest.json
    ├── 01-quest-doc.md
    ├── 02-ui-interaction-spec.md
    └── 03-acceptance.md
```

切图与页实现仍走既有约定：

```text
output/brand-ip/<slug>/05-ui-assets/<page>/
<flutter_app>/assets/images/<page>/
<flutter_app>/lib/features/<feature>/pages/<page>_page.dart
```

## Steward classification（瀑布，命中即停）

1. `quest.json` / 入参显式 `track: main|side` → 尊重人工（须有 `override_reason` 若与自动结果不同）
2. 绑定 `Fxx` 且落在 **MVP 闭环**（打开→干预→继续/放弃→统计）或 handoff/PRD 标 P0 未完成 → **main**
3. P0 基建（系统拦截、StoreKit/Play Billing、权限真机路径）→ **main**（`kind: infra`）
4. P1/P2、延后 Tab、纯动效/非闭环增强 → **side**
5. 无法映射 `Fxx` 且无法判断闭环 → **`needs_triage`**（只入待审，不自动开工）

每次判别必须写一句 `reason` 到 `steward-log.md`。

详情见 [references/classification-rules.md](references/classification-rules.md)。

## Dispatch policy

| 动作 | 行为 |
|------|------|
| 添加任务 | 判别 → 写入 `backlog.json`（`queued` / `needs_triage`）→ 同步 `BACKLOG.md` → 记 log |
| 开始下一个主线 | 取队列中最早的 `track=main` 且 `status=queued` → 脚手架 Quest 目录 → `status=doc` → **停在 Doc 确认门** |
| 主线未清空 | 默认不自动开工支线（可人工 `force_side=true`） |
| 禁止 | 无人确认跑完 Doc→Design→切图上线 |

## Per-quest pipeline（硬顺序）

```text
doc → design → page → done
```

| Stage | 必做 | Gate |
|-------|------|------|
| `doc` | 填 `01-quest-doc.md`（目标、入口/出口、状态机、Fxx、验收） | `validate_quest_stage.py … doc` |
| `design` | 填 `02-ui-interaction-spec.md`（元素、状态、交互；高级动效引用产品 `动画效果/动效.md` 或 `designing-advanced-app-interactions`） | `… design` |
| `page` | 按 `regenerating-ui-assets-to-flutter-page` 切图并实现页；填 `03-acceptance.md` 证据 | `… page` |
| `done` | 回写 `implementation-trace` 对应 `Fxx`；更新 backlog 状态 | `… done` |

**未 PASS 不得进入下一 stage。**

## Commands

在 `APP_WORKFLOW_ROOT` 下（或已 `export APP_WORKFLOW_ROOT`）：

```bash
# 初始化（每产品一次）
python3 05_Feature/feature-quest-steward/scripts/init_quests.py \
  docs/workflow/<slug>

# 添加任务（管家判别 + 入队）
python3 05_Feature/feature-quest-steward/scripts/enqueue_quest.py \
  docs/workflow/<slug> \
  --title "真系统拦截闭环" \
  --fxx F01,F03 \
  --priority P0 \
  --mvp-loop \
  --infra

# 仅预览判别
python3 05_Feature/feature-quest-steward/scripts/classify_quest.py \
  --fxx F10 --priority P0 --infra

# 开始下一个主线（生成目录，停在 doc）
python3 05_Feature/feature-quest-steward/scripts/start_next_main.py \
  docs/workflow/<slug>

# 阶段门
python3 05_Feature/feature-quest-steward/scripts/validate_quest_stage.py \
  docs/workflow/<slug>/quests/<quest_id> doc|design|page|done

# 队列健康
python3 05_Feature/feature-quest-steward/scripts/validate_quest_backlog.py \
  docs/workflow/<slug>/quests
```

## Agent workflow

1. Read this skill + [workflow-integration](references/workflow-integration.md).
2. Ensure `quests/` exists (`init_quests.py`).
3. On new feature brief → `enqueue_quest.py`（或先 `classify_quest.py` 给用户看理由）。
4. On「开始下一个主线」→ `start_next_main.py` → 与用户确认并写完 `01-quest-doc.md` → `validate … doc`。
5. 写 `02-ui-interaction-spec.md` → `validate … design`。
6. 执行 `regenerating-ui-assets-to-flutter-page`（读其 SKILL 全文）→ 证据写入 `03-acceptance.md` → `validate … page`。
7. 回写 trace / checklist → `validate … done`；更新 handoff `phases.features.quests_*`。
8. 不自动宣称 `gates.features = PASS`；整包仍跑 `implement-flutter-features` 校验。

## Handoff fields（可选）

```json
"phases": {
  "features": {
    "quests_dir": "docs/workflow/<slug>/quests",
    "quests_backlog": "docs/workflow/<slug>/quests/backlog.json",
    "active_quest_id": "q-001-…",
    "quests_steward_status": "ACTIVE"
  }
}
```

`quests_steward_status`: `NOT_REQUESTED` | `ACTIVE` | `BLOCKED_TRIAGE`。

## Scope rules

- 不修改 `flutter-app-template/template/`。
- 不跳过 Doc/Design 直接切图（除非用户书面豁免并记入 quest `waivers`）。
- Side 不得插队未完成的 Main，除非 `force_side`。
- 与 Phase 5 边界：本 Skill = 增量任务；`implement-flutter-features` = 整包 P0 与 `gates.features`。

## Failure policy

| 失败 | 动作 |
|------|------|
| `needs_triage` | 停；请用户补 Fxx / 优先级 / 是否闭环 |
| stage validator FAIL | 留在当前 stage |
| Main 队列非空却要开 Side | 拒绝，除非 `force_side` |
| 切图页失败 | 保持 `page`；不标 `done` |
