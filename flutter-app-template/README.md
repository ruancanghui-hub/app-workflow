# App 模板

独立维护的通用 Flutter **App 模板**仓库。本仓**不是**任一具体产品的业务 App；从本仓**模板源**生成的工程才是**模板实例**。

- **双端**：仅 iOS 与 Android。
- **分发**：以仓内 `template/` 为唯一**模板源**；用 `scripts/create_from_template.sh` 生成模板实例。

## Quick start

```bash
# Verify template layout
./scripts/verify_template_layout.sh --strict

# Create a template instance
./scripts/create_from_template.sh /tmp/my_app --project-name my_app --org com.example

# 唯一配置入口：编辑实例根 instance.config.yaml 后 apply
# ruby scripts/apply_instance_config.rb /tmp/my_app

# Run (dev)
cd /tmp/my_app
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
```

### 真机双击启动（macOS）

连接 iOS / Android **真机**后，双击仓根 [`run-device.command`](./run-device.command)（或实例根同名文件）：交互选择平台、设备与 `dev`/`prod`，再执行 `flutter run`。模拟器会被过滤掉。

### 快速开发面（默认依赖）

- UI：[forui](https://pub.dev/packages/forui)（锁定 `^0.25` 以兼容 Flutter 3.44；升 Flutter ≥3.47 后再升 0.26）
- 动效：[animations](https://pub.dev/packages/animations) / [shimmer](https://pub.dev/packages/shimmer) / [lottie](https://pub.dev/packages/lottie) / [rive](https://pub.dev/packages/rive)
- 启动品牌页、行为埋点事件表、帧卡顿监测、诊断入口：见 [ADR 0005](./docs/adr/0005-fast-dev-template-surface.md)

## 目录约定

| 路径 | 用途 |
|------|------|
| `template/` | **模板源**（含 Fastlane + deploy workflows） |
| `scripts/` | create / verify / iOS flavor 脚本 |
| `.github/workflows/` | 模板仓自身 CI（analyze / format / test） |
| `docs/` | 术语、ADR、接入清单、发布流水线 |

## 文档指针

- 术语：[docs/CONTEXT.md](docs/CONTEXT.md)
- ADR：[docs/adr/](docs/adr/)
- 模板源约定：[docs/flutter-create-template-conventions.md](docs/flutter-create-template-conventions.md)
- Firebase / 密钥：[docs/firebase-and-secrets.md](docs/firebase-and-secrets.md)
- 运营台 API 契约：[docs/ops-console-api.md](docs/ops-console-api.md)
- iOS flavors：[template/ios/FLAVORS.md](template/ios/FLAVORS.md)

## 已具备（中等厚度）

- GetX 路由 / Bindings / Controller（`feature → binding → controller → pages`）
- `dev` / `prod` **构建变体**（Android productFlavors + `APP_VARIANT`）
- **运维底座**端口：行为埋点 / 远程配置 / 缺陷定位（假实现默认；Firebase 适配器可选）
- HTTP（Dio）/ KV / 日志门面
- **应用实例身份** + **应用运营台**客户端心跳（无服务端）
- Fastlane **发布流水线**（TestFlight / Play internal；见 docs/fastlane-cicd.md）
- l10n + ThemeExtension **设计 token**
- Home / 设置演示页

## 明确不含

- 登录 / IdP、运营内容位 / CMS、业务组件库
- **应用运营台**服务端与管理 UI
