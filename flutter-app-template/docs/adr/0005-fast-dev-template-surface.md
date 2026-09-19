# 快速开发面：Forui + 动效套件 + 启动品牌页 + 帧卡顿监测 + 诊断入口

在 ADR 0004「中等厚度」之上，App 模板增加与具体产品无关的快速开发面：**模板组件**默认采用 [Forui](https://pub.dev/packages/forui)（当前工程锁定兼容 Flutter 3.44 的 `^0.25.0`；升级 Flutter ≥3.47 后再升 `0.26+`）、**动效套件**（[animations](https://pub.dev/packages/animations) / [shimmer](https://pub.dev/packages/shimmer) / [lottie](https://pub.dev/packages/lottie) / [rive](https://pub.dev/packages/rive)）、**启动品牌页**（原生启动图 + 可配置 slogan 的 Flutter 过渡）、类型化**行为埋点**事件表（仍走现有 Analytics 端口）、**帧卡顿监测**端口（默认 FrameTiming，不默认第二套 APM），以及 **prod 隐藏 / dev 可达** 的**诊断入口**。仍明确不含登录/IdP、运营内容位/CMS 与应用运营台服务端；不作与 Forui 平行的自研 UI Kit。

## 已定细则

- **模板组件**：Forui 经 `lib/core/ui/ui.dart` 全量导出；高频薄封装为 `AppButton` / `AppDialog` / `AppLoading` / `AppLoadingOverlay` / `AppToast` / `AppSkeleton` / `AppEmpty` / `AppSectionHeader`。不为每个 Forui 控件另写深度包装。
- **动效套件**：四包装入模板默认依赖；`SharedAxisGetPage` / `FadeThroughGetPage` / `FadeScaleGetPage`、`AppAppear`、`AppLottie` / `AppRive` 资源助手。不默认塞入大体积示例资源（Lottie/Rive 资源由实例添加）。
- **启动品牌页**：`flutter_native_splash` + Flutter 过渡页；logo/slogan/版权/最短时长来自**实例配置** → dart-define；展示初始化加载动画；仅冷启动展示；slogan 不走远程配置覆盖。
- **引导页**：默认 4 张可替换文案/图标的轮播；`APP_ONBOARDING_VERSION` + `KeyValueStore` 门控（`onboarding_seen_version`）；冷启动品牌页结束后按需进入；大版本可 bump 版本号再次展示。
- **行为埋点**事件表：仅模板级（`app_open` / `screen_view` / `jank_detected` / `diagnostics_open` / `onboarding_complete` / `rating_prompt` / `feedback_submit` 及现有 demo）；业务事件由模板实例扩展。供应商优先级见 ADR 0006。
- **应用内评分提示** / **用户反馈页**：`AppRatingPrompt` + Catalog 演示；反馈页无 HTTP（见 ADR 0006）。
- **帧卡顿监测**：阈值为约两帧（~33ms）；超阈采样上报行为埋点；功能开关 `jank_monitor_enabled`。
- **诊断入口**：`dev` 可达；`prod` 为 Home 标题连点 7 次，或功能开关 `diagnostics_entry_enabled` 为 true 时设置页也可进（手势 OR 开关）。检查项：构建变体、应用实例身份、Firebase 是否就绪、远程配置快照、最近卡顿次数、运营台心跳结果、复制诊断摘要。
- Round 3 落点：`lib/core/ui/`、`lib/core/branding/`、`lib/core/ops/` 扩展、`lib/features/diagnostics/`。
