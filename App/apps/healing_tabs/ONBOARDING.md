# 模板实例接入清单

每次从 **App 模板**生成新的 **模板实例** 时，用本清单登记「需要向谁申请什么、填到哪里」。  
**不提交密钥**；只在本机或 CI 密钥库保存真实值。

---

## 0. 生成模板实例

```bash
./scripts/create_from_template.sh <输出目录> \
  --project-name <包名> \
  --org <反向域名> \
  --app-id <应用实例身份 id> \
  --app-name <展示名>
```

脚本会种子化 **`instance.config.yaml`**（自 example + CLI），并运行 `apply_instance_config.rb` 生成 dart_defines / Secrets / `.env`。密钥请事后写入 config 再重新 apply。详见 [instance-config.md](./instance-config.md)。

| 字段 | 填写 | 示例 |
|------|------|------|
| 输出目录 | | `/path/to/my_app` |
| `--project-name` | Dart 包名（小写+下划线） | `my_app` |
| `--org` | Android/iOS 组织前缀 | `com.acme` |
| `--app-id` | **应用实例身份** id（运营侧唯一，prod） | `my_app` |
| `--app-name` | 应用展示名 | `My App` |

生成后默认标识：

| 平台 | dev | prod |
|------|-----|------|
| Android `applicationId` | `{org}.{project}.dev` | `{org}.{project}` |
| iOS Bundle ID | `{org}.{CamelCaseProject}`（当前未按变体拆分） | 同上 |
| dart-define `APP_INSTANCE_ID` | `{app-id}_dev` | `{app-id}` |

---

## 1. 外部账号与申请（先申请，后填表）

在写代码前，按需开通下列账号/资源。勾选本实例实际需要的项。

| # | 申请项 | 用途 | 需要？ | 负责人 | 申请状态 | 备注 |
|---|--------|------|--------|--------|----------|------|
| 1 | Apple Developer Program | iOS 真机调试与上架 | ☐ | | ☐ 未申请 ☐ 进行中 ☐ 已完成 | |
| 2 | App Store Connect 应用 | iOS 上架与 TestFlight | ☐ | | | Bundle ID 需与工程一致 |
| 3 | Google Play 开发者账号 | Android 上架 | ☐ | | | |
| 4 | Firebase 项目（dev） | **运维底座**：埋点 / 远程配置 / 缺陷定位 | ☐ | | | 可暂不申请，模板默认假实现 |
| 5 | Firebase 项目（prod） | 生产环境运维底座 | ☐ | | | 可与 dev 同项目不同 App，或分项目 |
| 6 | **应用运营台** 服务端地址 | 客户端心跳上报 | ☐ | | ☐ 未申请 ☐ 进行中 ☐ 已完成 | 无服务端可留空 |
| 7 | Android 发布 keystore | prod Release 签名 | ✅ 上架前 | | | 见 §3 / Fastlane |
| 8 | match 证书 git 仓库 | iOS CI 签名 | ✅ 上架前 | | | 见 [fastlane-cicd.md](./fastlane-cicd.md) |
| 9 | App Store Connect API Key | TestFlight / App Store 上传 | ✅ 上架前 | | | `.p8` 勿提交 |
| 10 | Play Console 服务账号 JSON | Play 上传 | ✅ 上架前 | | | 勿提交 |

---

## 2. 双端标识（申请后回填）

| 项 | dev | prod | 填到哪里 |
|----|-----|------|----------|
| Android `applicationId` | | | `android/app/build.gradle.kts` → `defaultConfig` / `productFlavors` |
| iOS Bundle ID | | | Xcode → Runner → Signing & Capabilities |
| iOS 显示名 | | | `Info.plist` → `CFBundleDisplayName`（如需与 Android 一致） |
| App Store Connect App ID | | | 运营台账（本仓不存） |
| Google Play 应用 ID | | | 运营台账 |

当前模板占位：`com.example.app_template`（Android）、`com.example.appTemplate`（iOS）。  
`create_from_template.sh` 会通过 `flutter create --org` 重写包名相关路径。

---

## 3. 签名与证书

优先写入 **`instance.config.yaml`** → `signing` / `platforms.ios.team_id`，再 `apply`。勿直接当源维护下列生成文件。

| 项 | 生成路径 | 状态 |
|----|----------|------|
| iOS `DEVELOPMENT_TEAM` | `ios/Flutter/Secrets.xcconfig` | ☐ |
| Android release keystore | `signing.android.keystore_path` + apply → `key.properties` | ☐ |

---

## 4. dart-define

由 `instance.config.yaml` 的 `identity` / `runtime` 经 apply 生成；勿手改 JSON。

| 文件 | 用途 |
|------|------|
| `dart_defines.dev.json` | 本地 / CI dev |
| `dart_defines.prod.json` | 本地 / CI prod；Fastlane 发布 |### 4.2 全部 dart-define 键

| 键 | 默认 | 必填？ | 说明 |
|----|------|--------|------|
| `APP_VARIANT` | `dev` | ✅ | 必须与 `--flavor` 一致：`dev` / `prod` |
| `APP_INSTANCE_ID` | `app_template_local` | ✅（实例） | **应用实例身份** id |
| `APP_INSTANCE_NAME` | `App Template` | ✅（实例） | 展示名 |
| `FIREBASE_CONFIGURED` | `false` | 接 Firebase 时 ✅ | `true` 才初始化真实 Firebase 适配器 |
| `OPS_CONSOLE_BASE_URL` | 空 | 接运营台时 ✅ | 空则心跳 no-op |

### 4.3 运行命令

```bash
# dev
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json

# prod
flutter run --flavor prod --dart-define-from-file=dart_defines.prod.json
```

---

## 5. Firebase / 运维底座（可选）

不接 Firebase 时，应用使用假实现，**可正常启动**。

| 步骤 | 文件（gitignore，勿提交） | dev | prod | 状态 |
|------|---------------------------|-----|------|------|
| 1 | `android/app/google-services.json` | ☐ | ☐ | |
| 2 | `ios/Runner/GoogleService-Info.plist` | ☐ | ☐ | |
| 3 | `lib/firebase_options.dart`（FlutterFire CLI） | ☐ | ☐ | |
| 4 | `dart_defines.*.json` 中 `FIREBASE_CONFIGURED: "true"` | ☐ | ☐ | |

申请路径：Firebase Console → 添加 Android / iOS 应用 → 下载配置文件。  
详见 [firebase-and-secrets.md](./firebase-and-secrets.md)。

---

## 6. 应用运营台（可选）

| 项 | 值 | 说明 |
|----|-----|------|
| `OPS_CONSOLE_BASE_URL` | | 例如 `https://ops.example.com` |
| 心跳接口 | `POST {BASE}/v1/heartbeat` | 见 [ops-console-api.md](./ops-console-api.md) |
| 上报 `appId` | 同 `APP_INSTANCE_ID` | |
| 上报 `displayName` | 同 `APP_INSTANCE_NAME` | |

---

## 7. iOS 构建变体一次性设置

Android `dev` / `prod` flavor 已在 Gradle 配好。iOS 需确保：

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Scheme `dev` / `prod` 存在 | ☐ | `ios/Runner.xcodeproj/xcshareddata/xcschemes/` |
| Build Configuration `Debug-dev` 等 | ☐ | create 脚本会调用 `setup_ios_flavor_build_configs.rb` |
| `ios/Flutter/Secrets.xcconfig` | ☐ | 由 apply 自 `platforms.ios.team_id` 生成 |
| `pod install` / `pod repo update` | ☐ | 首次 iOS 构建前；Firebase 插件对 CocoaPods 版本有要求 |

---

## 8. Fastlane / **发布流水线**（上线必填）

详见 [fastlane-cicd.md](./fastlane-cicd.md) 与 [instance-config.md](./instance-config.md)。

| 项 | 值 / 路径 | 状态 |
|----|-----------|------|
| 编辑 `instance.config.yaml` | 根目录 | ☐ |
| `ruby …/apply_instance_config.rb .` | 生成 `.env` 等 | ☐ |
| `bundle install` | 实例根 `Gemfile` | ☐ |
| match 初始化 | `cd ios && bundle exec fastlane match appstore` | ☐ |
| 本地试发 TestFlight | `cd ios && bundle exec fastlane beta` | ☐ |
| 本地试发 Play internal | `cd android && bundle exec fastlane beta` | ☐ |
| tag 触发 CI | `git tag vX.Y.Z && git push --tags` | ☐ |

---

## 9. 验收（全部填完后跑一遍）

```bash
cd <模板实例目录>
flutter pub get
flutter analyze
flutter test

# Android 真机 dev
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json -d <device_id>

# iOS 真机 dev（需完成 §7）
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json -d <device_id>
```

| 验收项 | 能跑（dev） | 能上线（prod） |
|--------|-------------|---------------|
| 能安装并打开 Home | ☐ | ☐ |
| 设置页显示正确 **构建变体** | ☐ | ☐ |
| `APP_INSTANCE_ID` / 展示名正确 | ☐ | ☐ |
| Firebase 埋点/崩溃 | 可选 | ☐（上架前建议） |
| 运营台心跳 | 可选 | ☐（若接运营台） |
| TestFlight / Play internal 上传成功 | — | ☐ |

---

## 附录：模板源维护项

| 项 | 说明 |
|----|------|
| iOS flavor Build Configuration | `scripts/setup_ios_flavor_build_configs.rb` |
| Fastlane / GHA | `template/ios/fastlane`、`template/android/fastlane`、`template/.github/workflows/deploy-*.yml` |
| Dart SDK 约束 | 与团队 Flutter 版本对齐 |
