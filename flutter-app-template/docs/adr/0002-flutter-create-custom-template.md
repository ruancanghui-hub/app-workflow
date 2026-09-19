# 以模板源目录分发 App 模板

App 模板以**独立仓库**维护。仓根承载 README、脚本与 CI；唯一**模板源**放在 `template/`，避免「可跑示例」与模板源双份手改漂移。实例化后得到**模板实例**，业务不回流进模板仓。

说明：Flutter CLI（3.x）的 `flutter create -t` 仅接受内置类型（`app` / `module` / …），**不能**把外部路径当作 `-t` 参数。本仓仍坚持「单一模板源」意图；具体消费命令与核对步骤见 `docs/flutter-create-template-conventions.md`（由仓库脚本从 `template/` 物化模板实例，必要时再用 `flutter create` 做平台修复）。
