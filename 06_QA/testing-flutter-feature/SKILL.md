---
name: testing-flutter-feature
description: >-
  每做完一个完整功能，对 Flutter 工程跑一次轻量回归：确定改动范围、只格式化改动文件、
  analyze 不新增问题、补功能 widget 测试（主路径 + 无障碍指南）、全量 flutter test、
  模拟器热重启截图、无障碍检查清单，最后在对话里报告 PASS / FAIL。
  Use when a Flutter feature is finished, before delivering or committing, or when the user says
  做完功能, 功能测试, 回归测试, 自动测试, feature test, 提交前检查.
---

# Testing a Flutter Feature

每做完一个功能就跑一遍，几分钟内给出可信结论。所有结论来自命令输出和截图，不凭感觉判断。

与 `automating-flutter-app-tests` 的区别：本技能针对单个功能、任何 Flutter 工程都能用、不依赖 `handoff-manifest.json` 和真机；全部功能完成、要过整体自动化测试门时，再用 `automating-flutter-app-tests`。

## Rules

- 测试失败就修 App 代码，不放宽断言、不删测试、不加 `skip`。
- 只格式化本次改动的文件；禁止 `dart format lib` 或 `dart format .`（会改动大量无关文件）。
- 改动文件里的 analyze error / warning 必须为 0；其他文件原有的问题只列出，不算失败。
- 没有截图证据，不能说“界面正常”。

## Workflow

下文 `<skill>` 指本技能目录（`~/.cursor/skills/testing-flutter-feature` 或 `~/.codex/skills/testing-flutter-feature`）。

### 1. 确定范围 + 2. 静态检查 + 4. 全量回归（脚本）

```bash
python3 <skill>/scripts/feature_check.py --app-dir <flutter 工程目录>
```

脚本依次：列出相对 `--base`（默认 `HEAD`）改动和未跟踪的 Dart 文件 → 对这些文件跑 `dart format`（在 base 版本里本来就没格式化过的旧文件会跳过，列在 `skipped_unformatted_at_base`，避免整文件重排淹没真实改动；这类文件手动保持原有风格）→ `flutter analyze` 并把问题分成“改动文件（阻塞）”和“已有问题” → `flutter test`。输出 JSON 摘要，最后一行是 `PASS` 或 `FAIL`。

| 参数 | 作用 |
|---|---|
| `--app-dir` | 工程目录；省略时从当前目录向上找 `pubspec.yaml` |
| `--base` | 比较基准，如 `main`、某个 commit；默认 `HEAD`（只看未提交改动） |
| `--tests` | 先单独跑这些测试文件（本功能的新测试），失败即停 |
| `--skip-full` | 跳过全量 `flutter test`（只在反复修单个测试时用，最终必须跑全量） |
| `--no-format` | 不格式化（只检查） |

先写第 3 步的测试，再跑脚本；脚本 FAIL 时按输出修复后重跑，直到 PASS。

### 3. 功能测试（必须写）

从 `<skill>/assets/feature_test.example.dart` 复制到 `<app>/test/<功能名>_test.dart`，只填页面和动作：

- **主路径**：进入页面 → 关键操作 → 断言结果（文本、跳转、状态变化）。
- **状态**：空数据、错误、加载中（功能里有的都要覆盖）。
- **无障碍指南**：`androidTapTargetGuideline`/`iOSTapTargetGuideline`（≥44pt）、`textContrastGuideline`（4.5:1）、`labeledTapTargetGuideline`。
- **回归守卫**（可选）：功能引入了约定（例如“只用某套图标”“禁止某个旧路径”），写一个扫描 `lib/` 的测试防止回退。

常见失败原因与解法见 `<skill>/references/pitfalls.md`，写测试前先看一遍。

### 5. 模拟器验证

- `flutter run` 已在后台运行：直接截图脚本会先热重启再截图。
- 没有在运行：先启动（`open -a Simulator`，再在工程目录 `flutter run -d <udid>` 后台运行），等首屏出现。

```bash
bash <skill>/scripts/sim_snap.sh <页面名> [输出目录]
```

默认输出 `output/qa/feature/<日期>/<页面名>.png`。每个改动页面截一张；进入二级页面时，用 App 内导航或深链进入后再截图（`--no-restart` 跳过热重启，避免回到首页）。

截图后**用读图工具逐张打开检查**：文字截断或省略号、元素错位或重叠、溢出条纹、安全区遮挡、选中态是否正确。发现问题 → 修代码 → 回到第 1 步。

用 osascript 按坐标点击模拟器不可靠：交互逻辑用第 3 步的 widget 测试覆盖，模拟器只负责视觉验证。

### 6. 检查清单与报告

逐项确认（能用测试断言的优先用测试断言）：

| 检查项 | 标准 |
|---|---|
| 对比度 | 正文 ≥ 4.5:1，大字 ≥ 3:1 |
| 点击区 | 所有可点元素 ≥ 44pt |
| 安全区 | 刘海、Home 指示条、底部导航不遮挡内容 |
| 减少动态效果 | `MediaQuery.disableAnimationsOf` 为 true 时跳过动画 |
| 文字 | 无截断、最小字号 ≥ 12 |
| 无障碍标签 | 图标按钮有 `Semantics` / `tooltip`，装饰元素排除语义 |

## Final response

先给结论（PASS / FAIL），再用一张表列出：改动文件数、analyze（阻塞 / 已有）、新增测试、全量测试通过数、截图数；嵌入截图；列出修复项与遗留项（已有问题、即将上线的入口等）。不要求生成报告文件。

## Common mistakes

- 只跑新测试，不跑全量 `flutter test`。
- 把已有 analyze 警告也顺手“修”掉，扩大改动范围。
- 截了图但没打开看。
- 为了让测试变绿而改断言，而不是修 App。
- 忘记功能的空状态 / 错误状态。
