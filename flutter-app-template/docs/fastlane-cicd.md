# Fastlane CI/CD

模板实例通过 **Fastlane** 自动构建并发布 **prod** 构建变体。

## 前置

1. 编辑实例根目录 **`instance.config.yaml`**（从 `instance.config.yaml.example` 复制；见 [instance-config.md](./instance-config.md)）
2. 应用配置：`ruby scripts/apply_instance_config.rb .`（生成 dart_defines / Secrets / key.properties / `.env`）
3. 完成 [instance-onboarding-checklist.md](./instance-onboarding-checklist.md) 中的账号申请（密钥填进 config）
4. `bundle install`

## 本地命令

```bash
bundle install

# iOS TestFlight（prod）
cd ios && bundle exec fastlane beta

# iOS App Store 上传（不自动提审）
cd ios && bundle exec fastlane release

# Android Play internal
cd android && bundle exec fastlane beta

# 仅构建不上传
cd ios && bundle exec fastlane build
cd android && bundle exec fastlane build
```

Flutter 构建参数固定为：

```bash
flutter build ipa|appbundle --release --flavor prod --dart-define-from-file=dart_defines.prod.json
```

## match（iOS 签名）

首次在本机初始化证书仓库：

```bash
cd ios
bundle exec fastlane match appstore
```

CI 使用只读模式（见 `deploy-ios.yml`）。

## GitHub Actions

| Workflow | 触发 | 产物 |
|----------|------|------|
| `deploy-ios.yml` | tag `v*` | TestFlight |
| `deploy-android.yml` | tag `v*` | Play internal track |

### 所需 Secrets

| Secret | 平台 | 说明 |
|--------|------|------|
| `APP_IDENTIFIER` | iOS | Bundle ID（prod） |
| `ANDROID_PACKAGE_NAME` | Android | applicationId（prod，无 `.dev` 后缀） |
| `APPLE_ID` | iOS | Apple 开发者账号 |
| `APPLE_TEAM_ID` | iOS | Team ID |
| `MATCH_PASSWORD` | iOS | match 加密密码 |
| `MATCH_GIT_URL` | iOS | 证书 git 仓库 |
| `MATCH_GIT_BASIC_AUTHORIZATION` | iOS | CI 访问 match 仓库（base64 `user:token`） |
| `APP_STORE_CONNECT_API_KEY_*` | iOS | App Store Connect API Key（推荐） |
| `ANDROID_KEYSTORE_BASE64` | Android | release keystore（base64） |
| `ANDROID_KEYSTORE_PASSWORD` | Android | keystore 密码 |
| `PLAY_STORE_JSON_KEY_BASE64` | Android | Play 服务账号 JSON（base64） |

## 发布流程

1. 更新 `pubspec.yaml` 版本号
2. 确认 `instance.config.yaml` → apply 后的 `dart_defines.prod.json`（含 `FIREBASE_CONFIGURED` 等）
3. 打 tag：`git tag v0.1.0 && git push origin v0.1.0`
4. CI 自动构建 prod 并上传 TestFlight / Play internal
