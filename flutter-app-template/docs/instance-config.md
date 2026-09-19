# 实例配置（单一入口）

每个**模板实例**只维护一份配置：`instance.config.yaml`。

## 流程

```bash
# 生成实例时已从 CLI 写入非密钥字段；也可手动：
cp instance.config.yaml.example instance.config.yaml

# 编辑密钥 / Team ID / 商店凭证后应用
ruby /path/to/flutter-app-template/scripts/apply_instance_config.rb .
# 若在 App 模板仓内改 template/ 本地试跑：
# ruby ../scripts/apply_instance_config.rb .
```

`apply_instance_config.rb` 会生成：

| 产物 | 用途 |
|------|------|
| `dart_defines.dev.json` / `dart_defines.prod.json` | `flutter run` / Fastlane 构建 |
| `ios/Flutter/Secrets.xcconfig` | `DEVELOPMENT_TEAM` |
| `android/key.properties` | Release 签名 |
| `.env`（及 `ios/fastlane/.env`、`android/fastlane/.env`） | Fastlane 环境变量 |

**不要手改这些产物**；改 `instance.config.yaml` 后重新 apply。

## 字段对照

见 `instance.config.yaml.example` 内注释。与旧分散文件的关系：

| 旧入口 | 现归入 |
|--------|--------|
| `dart_defines.*.json` | `identity` + `runtime` |
| `Secrets.xcconfig` | `platforms.ios.team_id` |
| `key.properties` | `signing.android.*` |
| `fastlane.env` / `.env` | `platforms` + `signing` + `deploy` |

密钥（密码、API Key、match password）写在 `instance.config.yaml`（gitignore）或 CI Secrets；CI 仍可用 GitHub Secrets 覆盖 `.env` 同名变量。

## 与发布

本地填好并 apply 后：

```bash
cd ios && bundle exec fastlane beta
```

详见 [fastlane-cicd.md](./fastlane-cicd.md)。
