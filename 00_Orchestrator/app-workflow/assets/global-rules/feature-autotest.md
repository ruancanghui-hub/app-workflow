## 功能完成后的自动测试（testing-flutter-feature）

在 Flutter 工程（有 `pubspec.yaml`）里完成一个完整功能后，交付或提交前必须使用 `testing-flutter-feature` 技能跑完一轮功能级自动测试：补功能测试、运行 `feature_check.py`（只格式化改动文件、analyze 改动文件零 error/warning、全量 flutter test）、模拟器截图并逐张检查、过无障碍检查清单。结果为 `PASS` 才算功能完成；`FAIL` 时修 App 代码后重跑，不放宽断言。最终回复里报告 PASS / FAIL、测试数量与截图。
