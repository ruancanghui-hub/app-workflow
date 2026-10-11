# 自动化测试报告 — {{app_name}}

- **product_slug**: {{slug}}
- **日期**: {{date}}
- **commit**: {{commit}}
- **模拟器**: {{simulator}}
- **真机**: {{device}}
- **结果数据**: {{results_json}}

> 结论均来自 `run_autotest.py` 的测试输出。模拟器只有 debug 构建，帧数据只作上限参考；release 级结论以 L3 真机 profile 为准。

## L1 组件质量（flutter test）

| 项 | 结果 | 说明 |
|---|---|---|
{{l1_rows}}

## L2 模拟器（flutter drive，debug）

### 主路径

| 轮次 | 结果 | 首屏 ms | 用时 s |
|---|---|---|---|
{{main_loop_rows}}

### 系统能力

| 项 | 期望 | 实测 | 结果 |
|---|---|---|---|
{{system_rows}}

### 帧耗时（按动作）

| 动作 | 帧数 | build p50 | build p90 | build max | raster p90 | >16ms | 结果 |
|---|---|---|---|---|---|---|---|
{{perf_rows}}

截图：{{screenshots}}

## L3 真机（profile）

- **状态**: {{l3_status}}
- **用户确认**: {{l3_confirmed_by}}

| 项 | 期望 | 实测 | 结果 |
|---|---|---|---|
{{l3_rows}}

### 手动清单（真机，L3 为 done 时全部勾选）

- [ ] 通知真实弹出，点击直达对应页面
- [ ] 系统分享面板可分享到微信
- [ ] 写入相册后在“照片”中可见
- [ ] VoiceOver 走完主路径
- [ ] 飞行模式下主路径可降级

## 阻塞项

| # | 层 | 描述 | 状态 | 证据 |
|---|---|---|---|---|
{{blocker_rows}}

状态取值：open / fixed / deferred。存在 open 时总 Gate 不能为 PASS。

## 总 Gate

- **autotest_gate**: {{gate}}
- **说明**: {{gate_note}}
