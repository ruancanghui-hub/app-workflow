# App 模板中等厚度的能力边界

模板在 GetX 与运维底座之外，默认提供：HTTP 客户端骨架、本地 KV 存储接口、日志门面；以及用于验收的 Home/设置演示（构建变体、行为埋点、功能开关、仅 dev 可触发的测试异常）。**不包含**登录/IdP、运营内容位/CMS、完整 UI Kit。快速开发面（模板组件、启动品牌页、帧卡顿监测、诊断入口等）见 [0005](./0005-fast-dev-template-surface.md)。密钥与 Firebase 工程仅占位，经本地未提交配置或 `--dart-define` 接入。工程规范以 `flutter_lints` 加小幅加严为准；CI 为 analyze/format/单测示例 + GitHub Actions。落地顺序：先独立模板仓可用，再生成模板实例。
