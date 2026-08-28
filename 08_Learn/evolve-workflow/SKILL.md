---
name: evolve-workflow
description: >-
  记录开发中重复出现的摩擦，第三次自动晋升为 Playbook 并反哺工作流技能。
  Use when the same step was repeated 3 times, 沉淀工作流, workflow evolution,
  log repetition, or promote playbook.
---

# Evolve Workflow（规则之三）

**同一摩擦在不同项目或迭代中出现第 3 次，必须沉淀为 Playbook**，并挂接到对应阶段 Skill，使流水线自我成长。

## Core principle

Chat is ephemeral; playbooks are permanent. Measure repetition in `registry/repetition-log.json`, not memory.

## Registry

全局登记簿（跨产品共享）：

```
00_Orchestrator/app-workflow/registry/repetition-log.json
```

初始化（若不存在）：

```bash
cp 08_Learn/evolve-workflow/assets/repetition-log.template.json \
   00_Orchestrator/app-workflow/registry/repetition-log.json
```

## When to log

在 **任意阶段**（PRD / IP / 原型 / 脚手架 / 功能 / QA / 上架）遇到以下情况时记录：

- 相同操作步骤第二次在同一产品出现 → **观察**
- **第三次**（跨产品累计或同产品累计）→ **必须晋升 Playbook**
- 用户明确说「又做了一遍」→ 立即 `log`

## Log a repetition

```bash
python3 08_Learn/evolve-workflow/scripts/log_repetition.py \
  --phase features \
  --pattern "iOS Xcode 复制 dev/prod scheme" \
  --context "第三个 App 实例再次手动配置 FLAVORS" \
  --product-slug yunyao_sleep
```

输出示例：`count=3 → PROMOTE_REQUIRED`

## Promote to playbook（count ≥ 3）

```bash
python3 08_Learn/evolve-workflow/scripts/promote_to_playbook.py \
  --pattern-id <id_from_log> \
  --title "iOS Flavor Scheme 一次性配置"
```

脚本会：

1. 在 `00_Orchestrator/app-workflow/playbooks/<phase>/<slug>.md` 创建 Playbook（自 `assets/playbook.template.md`）
2. 更新 `registry/repetition-log.json` 条目的 `playbook_path` 与 `status=promoted`
3. 在 `playbooks/INDEX.md` 追加一行索引
4. 打印 **建议反哺** 的目标 Skill 路径（人工或 Agent 合并进对应 `SKILL.md` / `references/`）

## Playbook 契约

每个 Playbook 必须包含：

| 段 | 内容 |
|----|------|
| 触发条件 | 何时套用 |
| 前置 | 工具、账号、路径 |
| 步骤 | 可复制命令，禁止含糊 |
| 验收 | 如何确认完成 |
| 反哺记录 | 已写入哪个 Skill 文件、哪一节 |

## 反哺规则

晋升 Playbook 后 **同一发布周期内** 完成反哺之一：

1. **首选**：写入对应阶段 `references/<topic>.md`，并在该阶段 `SKILL.md` 加链接
2. **流程性步骤**：写入 `00_Orchestrator/app-workflow/SKILL.md` 对应 Phase
3. **可自动化**：在 `scripts/` 增加脚本并在 Skill 引用

在 Playbook 顶部 YAML 记录：

```yaml
promoted_to:
  - path: 04_Dev/create-flutter-app/references/ios-flavors.md
    section: "One-time scheme setup"
```

## 与 grill-with-docs 对齐

每次晋升同时更新：

- `docs/workflow/<product_slug>/glossary.md` — 新术语
- `docs/workflow/<product_slug>/adr/` — 若决策影响架构（如默认 iOS 优先上架策略）

## 阶段结束回顾（必做）

每个 Phase Gate PASS 后，Agent 问一句：

> 本阶段有没有你想记下来、下次不想重做的步骤？

有则 `log_repetition.py`；count≥3 则当场 `promote_to_playbook.py`。

## Final response

Report pattern id, count, playbook path if promoted, and which Skill files still need merge.

## Common mistakes

- Discussing repetition only in chat.
- Promoting vague playbooks without commands.
- Creating playbooks but never linking them from child skills.
