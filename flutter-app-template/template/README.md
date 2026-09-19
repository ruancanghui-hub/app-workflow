# 模板源

唯一 **模板源** 蓝本（包名占位 `app_template`）。复制本目录生成**模板实例**；不要在仓库其他位置维护第二份示例工程。

含 GetX、运维端口、构建变体、l10n、设计 token、Home/设置演示、Fastlane **发布流水线**。

- 接入清单：仓库 `docs/instance-onboarding-checklist.md`（create 后复制为实例根 `ONBOARDING.md`）
- **唯一配置**：`instance.config.yaml` → `scripts/apply_instance_config.rb`（见 `docs/instance-config.md`）
- 发布：`docs/fastlane-cicd.md`；本地 `bundle install` 后 `cd ios && bundle exec fastlane beta`
- 密钥与 Firebase：仓库 `docs/firebase-and-secrets.md`
