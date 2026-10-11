# 已踩过的坑

## 测试编写

- **IndexedStack 中不可见的子页**：finder 默认跳过 offstage 组件。先切到对应 Tab 再查找，或用 `find.byType(...)` 限定在可见区域。
- **多个滚动容器**：`find.byType(Scrollable).at(n)` 容易越界。用 `find.byType(ListView)` / `CustomScrollView` 精确定位。
- **生命周期切换**：必须按合法顺序。进后台：resumed → inactive → hidden → paused；回前台倒序。直接 paused → resumed 会触发断言。
- **GetX 依赖**：被 `Get.delete` 或路由回收的服务在测试里会报 “not found”。存储类服务用 `Get.put(..., permanent: true)`。
- **大字号测试**：用 `tester.platformDispatcher.textScaleFactorTestValue`，测试结束调用 `clearTextScaleFactorTestValue()`；溢出靠自定义 `FlutterError.onError` 收集，不然只看到第一个错误。
- **App 自己限制了字号**（`MediaQuery.withClampedTextScaling`）：×2.0 实际被限到上限，测试依然要跑，以确认限制生效。

## 无障碍

- `Semantics(excludeSemantics: true)` 会丢掉子组件的 tap 动作：必须在外层 `Semantics` 上提供 `onTap`。
- 开关行用 `MergeSemantics` 包住标题与 `Switch`，否则开关没有标签。
- Chip / 小图标按钮视觉小于 44pt：增加 padding 或 `minHeight`，不要只靠 `hitTestBehavior`。
- 浅金色、浅灰文字常不过 4.5:1：为文字单独定义加深色值，背景装饰色保持不变。

## 模拟器

- applesimutils 只在 drive 前执行一次，之后等 8 秒（见 `simulator-permissions.md`）。
- 模拟器不支持 `--profile`；帧数据只作参考。
- 首次 `xcodebuild` 很慢（数分钟），脚本超时要放宽。
- 截图依赖 `IntegrationTestWidgetsFlutterBinding.takeScreenshot`，在 iOS 上要先 `convertFlutterSurfaceToImage()`（仅首次）。

## App 侧常见修复

- 启动阻塞：不要在 `runApp` 前 await 磁盘、FFI 插件或通知队列。
- 商店请求无超时：给 `queryProductDetails` 等调用加超时，失败分成“未找到”与“失败”两类提示。
- 编辑页切后台丢内容：控制器实现 `WidgetsBindingObserver`，在 paused / hidden 时存草稿。
