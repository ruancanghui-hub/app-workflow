---
name: create-flutter-app
description: >-
  从 flutter-app-template（yunyao main：Forui、友盟、运维底座、GetX、dev/prod）生成新 Flutter 实例。
  Use when the user wants a new app, new Flutter project, 从模板创建、实例化 App、
  scaffold mobile app, or start business development on a fresh template instance.
---

# 从 App 模板创建新应用

## 模板路径

本 monorepo 内模板仓根目录：

`flutter-app-template/`

- **权威来源（必须对齐 main）**：https://github.com/ruancanghui-hub/yunyao/tree/main/flutter-app-template  
  含 Forui、友盟统计优先、Lottie/Rive/动效套件、启动品牌页等（以远程 `template/pubspec.yaml` 为准）
- **模板源**：`flutter-app-template/template/`
- **创建脚本**：`flutter-app-template/scripts/create_from_template.sh`
- **布局校验**：`flutter-app-template/scripts/verify_template_layout.sh`
- **同步脚本**：`00_Orchestrator/app-workflow/scripts/sync_flutter_app_template.sh`

### 同步最新模板（每次脚手架前）

禁止长期依赖过期的本地副本或指向旧仓的 symlink。脚手架前执行：

```bash
export APP_WORKFLOW_ROOT="$(readlink -f ~/.cursor/skills/app-workflow-root 2>/dev/null || readlink ~/.cursor/skills/app-workflow-root)"
bash "$APP_WORKFLOW_ROOT/00_Orchestrator/app-workflow/scripts/sync_flutter_app_template.sh"
```

验收：`flutter-app-template/.template-source-commit` 已更新；`template/pubspec.yaml` 含当前 main 依赖（如 `forui`、`umeng_common_sdk`）。

若工作区不是本 monorepo，仍以 `$APP_WORKFLOW_ROOT/flutter-app-template` 为准（Cursor/Codex 经 `app-workflow-root` 指向同一路径）。

## 输入（缺则向用户确认）

| 参数 | CLI | 规则 |
|------|-----|------|
| 输出目录 | `<output_dir>` | 目录**不得已存在**；monorepo 默认 `apps/<project_name>/` |
| Dart 包名 | `--project-name` | snake_case，如 `yunyao_sleep` |
| 组织域 | `--org` | 如 `com.yunyao` |
| 应用实例 ID | `--app-id` | 运营侧唯一 id，如 `yunyao_sleep_v1` |
| 展示名 | `--app-name` | 如 `云遥睡眠` |

未给 `--app-id` / `--app-name` 时脚本用 `project_name` 与 `project_name_local` 填充。

## 执行序列

**完成标准**：新目录存在、`dart analyze` 通过、已向用户说明如何 `flutter run`。

1. **Sync + Preflight**

```bash
bash "$APP_WORKFLOW_ROOT/00_Orchestrator/app-workflow/scripts/sync_flutter_app_template.sh"
cd "$APP_WORKFLOW_ROOT/flutter-app-template"
./scripts/verify_template_layout.sh --strict
```

失败则先修模板源或重跑 sync，不要强行创建实例。

2. **Create**

```bash
./scripts/create_from_template.sh <output_dir> \
  --project-name <project_name> \
  --org <org> \
  --app-id <app_id> \
  --app-name "<app_name>"
```

脚本会 rsync 模板源、`flutter create` 修复双端、写入 `dart_defines.dev.json`、`dart analyze lib test`。

3. **Smoke（推荐）**

```bash
cd <output_dir>
flutter test
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
```

Android 可直接 `--flavor dev`。iOS 需先按 `ios/FLAVORS.md` 在 Xcode 复制 `dev`/`prod` scheme（模板未自动改 pbxproj）。

4. **Monorepo 收尾（在 yunyao 仓内时）**

- 将 `apps/<name>/` 纳入 git（勿提交 `build/`、`.dart_tool/`）
- 业务 spec / tickets 放 `.scratch/<app-name>/`，术语对齐根 `CONTEXT.md`

## 创建后可选配置

| 需求 | 做法 |
|------|------|
| Firebase 真适配器 | 见 [reference.md](reference.md#firebase) |
| 应用运营台心跳 | `OPS_CONSOLE_BASE_URL` dart-define |
| prod 变体 | `--flavor prod --dart-define=APP_VARIANT=prod` |

不配 Firebase / 运营台时，假实现默认可跑。

## 业务开发约定

新实例沿用模板结构，勿改模板源 `flutter-app-template/template/`：

- `lib/features/<feature>/` → `binding` → `controller` → `pages`
- 运维能力走端口（Analytics / RemoteConfig / CrashReporter），经 GetX Binding 注入
- 构建变体：`APP_VARIANT` 必须与 `--flavor` 一致（`dev` 或 `prod`）

详细配置与 gotcha 见 [reference.md](reference.md)。

## 示例（云遥睡眠 MVP）

```bash
cd flutter-app-template
./scripts/create_from_template.sh ../apps/yunyao_sleep \
  --project-name yunyao_sleep \
  --org com.yunyao \
  --app-id yunyao_sleep_v1 \
  --app-name "云遥睡眠"
```

运行：

```bash
cd ../apps/yunyao_sleep
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
```
