# 功能测试常见坑

每条都是真实踩过的：症状 → 原因 → 解法。

## 1. `No Material widget found`

- **症状**：页面里有 `TextField`、`InkWell`、`ListTile`，单独 `pumpWidget(MaterialApp(home: Page()))` 时报错；在 App 里却正常。
- **原因**：App 里外层 `Scaffold` 提供了 `Material`，页面自身的根是 `ColoredBox` / `Container`。
- **解法**：修 App，让页面根部提供 `Material(color: ...)` 或 `Scaffold`。不要只在测试里包一层 `Scaffold` 掩盖问题。

## 2. `pumpAndSettle timed out`

- **症状**：页面有呼吸、旋转、闪烁等动效，`pumpAndSettle` 一直等不到稳定。
- **原因**：`AnimationController.repeat()` 无限循环。
- **解法**：动效限定次数 `repeat(reverse: true, count: 3)`，或在 `MediaQuery.disableAnimationsOf(context)` 为 true 时不启动；测试里无法避免时改用 `pump(const Duration(milliseconds: 500))`。

## 3. `A Timer is still pending even after the widget tree was disposed`

- **症状**：错峰入场动画用 `Future.delayed` / `Timer` 做延迟，测试结束时报未完成的 timer。
- **解法**：延迟放进动画曲线里：控制器总时长 = 延迟 + 入场时长，曲线用 `Interval(delay / total, 1, curve: ...)`。

## 4. `find.text` 找到两个

- **症状**：输入框里输入“极客”后断言 `find.text('极客')` 为 `findsOneWidget` 失败，找到 2 个。
- **原因**：`find.text` 也会匹配 `EditableText` 里的内容。
- **解法**：限定范围：`find.widgetWithText(GridView, '极客')` 或 `find.descendant(of: find.byType(GridView), matching: find.text('极客'))`。

## 5. 同一文字出现多次

- **症状**：底部 Tab 文字与页面标题相同，`tap(find.text('我的'))` 报找到多个。
- **解法**：`find.text('我的').last`，或用 `find.bySemanticsLabel('我的')`，或给目标加 `Key`。

## 6. `dart format lib` 误改大量文件

- **症状**：格式化后 git diff 出现几十个无关文件；或者只改了一行图标，整个文件被重排出上百行 diff。
- **原因**：旧文件在 base 版本里本来就不符合 `dart format`。
- **解法**：只格式化改动文件，并跳过 base 版本未格式化的旧文件（`feature_check.py` 已自动做，跳过的文件列在 `skipped_unformatted_at_base`）。已误操作时：对每个无关文件，比较“HEAD 版本格式化后”与当前内容，一致就 `git checkout -- <file>`；有自己改动的文件只保留真实改动。

## 7. 视口不一致导致溢出 / 找不到元素

- **症状**：默认测试视口是 800x600，手机布局溢出或元素在屏幕外点不到。
- **解法**：固定手机视口并在结束时还原：

```dart
tester.view.physicalSize = const Size(390, 844);
tester.view.devicePixelRatio = 1;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
```

屏幕外元素先 `await tester.ensureVisible(finder)` 再点击。

## 8. 依赖 GetX / 单例的页面

- **症状**：`Get.find` 找不到 controller。
- **解法**：测试里先 `Get.put(...)` 或调用页面的 Binding；`tearDown(Get.reset)` 清理，避免用例互相影响。

## 9. 模拟器按坐标点击不生效

- **症状**：osascript `click at {x, y}` 点底部 Tab 有效，点页面内的筛选标签无效。
- **解法**：交互逻辑用 widget 测试覆盖；模拟器只做视觉验证（热重启 + 截图）。

## 10. 热重启后状态丢失

- **症状**：`kill -USR2` 热重启后回到首页，截不到二级页面。
- **解法**：热重启一次后用 App 内导航进入目标页，再 `sim_snap.sh <名称> --no-restart` 截图；热重载用 `USR1`（保留状态）。
