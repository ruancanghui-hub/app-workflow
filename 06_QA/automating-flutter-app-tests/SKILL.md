---
name: automating-flutter-app-tests
description: >-
  功能门通过后，对 Flutter App 自动跑三层测试：组件级质量扫描（无障碍指南、动态字体溢出、
  VoiceOver 语义、弱网与中断）、模拟器真实插件验证（主路径 ×3、首屏、通知待发队列、
  相册授权/拒绝、商店降级、按动作帧耗时、截图）、真机 profile 测试，产出 autotest-report 并过自动化测试门。
  Use when gates.features is PASS, or the user asks for 自动化测试, 模拟器测试, 真机测试,
  autotest, regression run, or wants evidence before QA polish.
---

# Automating Flutter App Tests

把“做完功能 → 能不能交给 QA 打磨”变成一次可重复的自动运行。所有结论来自测试输出，不凭感觉判断。

## Prerequisites

- `gates.features == "PASS"`（`handoff-manifest.json`）
- Flutter 工程：`phases.flutter.output_dir`；flavor 与 dart-define 文件按工程约定（模板默认 `--flavor dev --dart-define-from-file=dart_defines.dev.json`）
- macOS + Xcode；至少一台已启动的 iOS 模拟器
- 可选：`applesimutils`（预置通知权限；安装需用户同意 `brew trust wix/brew`）
- 可选：已连接、已解锁、开启开发者模式的 iPhone（L3）

## Inputs

| 来源 | 用途 |
|---|---|
| `implementation-trace.md` | P0 页面清单与主路径 |
| `02-交互说明文档.md` | 必测状态（空 / 错误 / 权限 / 离线 / 中断） |
| PRD 非功能需求 | 冷启动、导出、帧率、对比度、动态字体预算 |
| `references/metrics-thresholds.md` | 判定标准 |

## Workflow

### 0. 预检

```bash
python3 06_QA/automating-flutter-app-tests/scripts/detect_test_targets.py
```

输出 JSON：已启动的模拟器（UDID）与真机（ID / 状态）。没有可用真机时，询问用户一次：接上真机，或 L3 记为 deferred。用户确认 deferred 后，在报告里写明确认人。

### 1. 把测试工具装进 App（每个 App 一次）

从 `assets/` 拷贝，不修改工具本身：

| 资产 | 目标位置 |
|---|---|
| `test_support/quality_harness.dart` | `<app>/test/support/quality_harness.dart` |
| `integration_support/frame_probe.dart` | `<app>/integration_test/support/frame_probe.dart` |
| `integration_support/launch_probe.dart` | `<app>/integration_test/support/launch_probe.dart` |

再参照两个示例，为本 App 写测试，只需填写“页面清单 + 进入方式 + 主路径动作”：

- `assets/quality_test.example.dart` → `<app>/test/app_quality_test.dart`（L1）
- `assets/qa_simulator_test.example.dart` → `<app>/integration_test/qa_simulator_test.dart`（L2 / L3）

主路径截图测试（若已有，如 `integration_test/tab_screens_test.dart`）在启动处加 `LaunchProbe`，输出 `QA first screen`。

### 2. L1 组件质量（`flutter test`）

每个 P0 页面：

- `labeledTapTargetGuideline`、`iOSTapTargetGuideline`（≥44pt）、`textContrastGuideline`（WCAG 4.5:1）
- 字号 ×1.35 与 ×2.0：`collectLayoutErrors` 收集全部溢出并带 `lib/...dart:行号`
- VoiceOver：主路径节点有标签、按钮语义、选中态；`excludeSemantics` 的控件仍有 tap 动作
- 弱网与中断：商店 / 网络端口断开时的提示与超时；编辑中切后台即存草稿（生命周期按合法顺序切换）

失败即修 App 代码（不是放宽测试），修完重跑直到全部通过。

### 3. L2 模拟器（`flutter drive`，真实插件）

```bash
python3 06_QA/automating-flutter-app-tests/scripts/run_autotest.py <app_dir> \
  --slug <product_slug> --simulator <udid> \
  --main-loop integration_test/tab_screens_test.dart \
  --qa-target integration_test/qa_simulator_test.dart \
  --workflow-dir docs/workflow/<product_slug> \
  --output-dir output/qa/<product_slug>
```

脚本依次：`dart analyze` → `flutter test` → 主路径 drive ×N（默认 3）→ 预置权限后跑 QA 探针（相册授权一轮、拒绝一轮）→ 有 `--device` 时跑 L3 → 解析 `QA ...` 行 → 写 `autotest-results.json` 与 `autotest-report.md` 草稿。

QA 探针约定的输出行（由 `assets/` 工具打印，脚本解析）：

| 行前缀 | 含义 |
|---|---|
| `QA first screen: <ms> ms` | 启动到首屏可交互 |
| `QA perf <动作>: frames=… build p90=… over16ms=…` | 按动作帧耗时 |
| `QA notifications planned=<n> pending=<m>` | 真实写入 iOS 待发队列 |
| `QA album(<granted/denied>) -> <outcome>` | 相册写入 / 拒绝降级 |
| `QA store buy started=<bool> in <ms> ms` | 商店不可用时的降级耗时 |
| `QA export render: <ms> ms` | 导出渲染耗时 |

权限细节见 `references/simulator-permissions.md`。

### 4. L3 真机（有设备时）

同一 QA 探针以 `--profile` 跑在 iPhone 上（`run_autotest.py ... --device <id>`），得到 release 级帧率与冷启动。再按报告模板里的手动清单走查：通知真实弹出并点击直达、系统分享到微信、写入相册、VoiceOver 主路径、飞行模式。

### 5. 补全报告并过门

脚本生成的 `docs/workflow/<product_slug>/autotest-report.md` 是草稿：补上阻塞项（fixed / deferred）、人工结论与截图链接，然后：

```bash
python3 06_QA/automating-flutter-app-tests/scripts/validate_autotest_report.py \
  docs/workflow/<product_slug>/autotest-report.md
```

必须打印 `PASS`。随后在 handoff：`gates.autotest = "PASS"`，`phases.qa.autotest_report = "autotest-report.md"`，`phases.qa.autotest_results` 指向 `autotest-results.json`，`phases.qa.autotest_targets` 记录模拟器与真机；再跑编排器 `validate_handoff.py`。旧项目的 manifest 没有 `gates.autotest` 键时，先补上 `"autotest": "PENDING"`。

## Pass criteria

| 层 | 标准 |
|---|---|
| L1 | 全部 P0 页面三条指南通过；×1.35 / ×2.0 零溢出；VoiceOver 断言通过 |
| L2 | 主路径连续 N 遍成功；通知 pending == planned；相册授权 saved、拒绝 albumDenied；商店降级在超时内返回且不卡忙碌态 |
| L2 帧耗时 | 无连续掉帧；debug 下超过 16ms 的帧 ≤10%，且集中在首次构建（见 `metrics-thresholds.md`） |
| L3 | 真机数据满足 PRD 预算；或 deferred + 用户确认 |

## Required output

```
docs/workflow/<product_slug>/autotest-report.md
output/qa/<product_slug>/autotest-results.json
output/qa/<product_slug>/*.png                  # 主路径截图
<app>/test/app_quality_test.dart
<app>/integration_test/qa_simulator_test.dart
```

## Final response

用表格给出 L1 / L2 / L3 结论与关键数字（首屏、帧耗时、通知、相册、商店），列出修复项与 deferred 项，报告链接与门状态。Phase 6 QA 打磨直接引用这些数据。

## Common mistakes

- 只跑 happy path 截图，不跑无障碍指南与大字号。
- 放宽断言让测试变绿，而不是修 App。
- 把 debug 模拟器帧数据当成 release 结论。
- 循环调用 applesimutils（会反复重启 SpringBoard，导致 App 启动失败）。
- 通知 pending=0 就判定代码有问题（先确认已授权）。
- 没有真机时静默跳过 L3，不写 deferred 和用户确认。
