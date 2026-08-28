---
name: polish-app-quality
description: >-
  对 Flutter MVP 做 QA 与体验打磨：性能、动画、触觉、无障碍、弱网与真机验收。
  Use when features are implemented and user wants QA, polish, 体验打磨, 丝滑优化,
  or pre-release quality gate before App Store.
---

# Polish App Quality

把原型里定义的「丝滑」变成可测量的 PASS/FAIL。在提审前消灭主路径 jank、状态缺失和可访问性硬伤。

## Prerequisites

- `gates.features == "PASS"`
- `02-交互说明文档.md` 与 `implementation-trace.md` 可读
- Dev build 可在真机运行（iOS 优先时至少一台 iPhone）

## Inputs

| 来源 | 用途 |
|------|------|
| `02-交互说明文档.md` | 必测状态与手势 |
| PRD NFR 段落 | 性能/离线指标 |
| `implementation-trace.md` | 主路径范围 |
| `references/performance-rubric.md` | 评分标准 |

## Workflow

1. 从 `assets/qa-checklist-template.md` 创建 `docs/workflow/<product_slug>/qa-report.md`。
2. **主路径演练**（MVP loop 至少 3 遍）：记录首屏时间、过渡卡顿、返回栈、中断恢复。
3. **状态覆盖**：逐页验证 loading / empty / error / permission-denied / offline。
4. **性能**：`flutter run --profile`；关注 >16ms 帧；列表滚动与 hero 动画。
5. **无障碍**：Semantics、Dynamic Type、对比度、VoiceOver 核心路径。
6. **弱网**：飞行模式 / Network Link Conditioner 下主路径可降级。
7. 修复阻塞项；无法修复的记入 `qa-report.md` → 风险段并需用户签字 defer。
8. 每次重复出现的 QA 步骤（第三次）→ `08_Learn/evolve-workflow` 沉淀为 playbook。
9. Gate:

```bash
python3 06_QA/polish-app-quality/scripts/validate_qa_report.py \
  docs/workflow/<product_slug>/qa-report.md
```

10. Set `gates.qa = "PASS"`; rerun handoff validator.

## Pass criteria (MVP)

| 项 | 标准 |
|----|------|
| 主路径 | 无崩溃；3 遍连续成功 |
| 帧率 | 主路径无明显 jank（主观 + profile 无连续掉帧） |
| 状态 | P0 页面五态均有 UI 与文案 |
| 无障碍 | 核心 CTA 有 label；动态字号不截断主文案 |
| 触觉/动画 | 主 CTA 有反馈；过渡 200–350ms 量级 |

## Required output

`docs/workflow/<product_slug>/qa-report.md` — 含阻塞项、已修复、defer 项、真机型号、build 号。

## Final response

Summary table of pass/fail per checklist section, link qa-report, gate status, remaining deferrals.

## Common mistakes

- Only testing happy path on simulator.
- Treating aesthetic preference as PASS without metric.
- Skipping qa-report file and claiming "feels smooth".
