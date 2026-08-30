# Implementation Trace — healing_tabs

| MVP 需求 ID | 用户目标 | 代码路径 | 测试路径 | 状态 | 验收证据 |
|---|---|---|---|---|---|
| P0-01 声景发现 | 首页/声音 Tab 找到今晚声景 | lib/features/sound_catalog/widgets/sound_library_sheet.dart | test/sound_catalog_controller_test.dart | implemented | 动态目录+声景库 sheet；搜索/加号/首页菜单入口 |
| P0-02 声景播放 | 低摩擦开始伴睡 | lib/features/player/player_controller.dart | test/player_controller_test.dart | implemented | just_audio 真实播放；loading/playing/paused/error 状态机 |
| P0-03 收藏与离线 | 收藏常用声景 | lib/features/sound_catalog/widgets/sound_library_sheet.dart | test/sound_catalog_test.dart | implemented | 声景库内收藏切换；设置「我的收藏」入口 |
| P0-04 睡眠会话 | 记录会话开始/结束 | lib/features/sleep_session/sleep_session_controller.dart | test/sleep_session_controller_test.dart | implemented | 睡眠 Tab 播放钮→会话页→结束保存 |
| P0-05 轻唤醒 | 柔和本地唤醒 | — | — | deferred | MVP+1：固定时间 + 单一内置铃声 + 30s 渐强 |
| P0-06 基础报告 | 在床时长与主观评分 | lib/features/sleep_session/widgets/sleep_history_sheet.dart | test/sleep_session_controller_test.dart | implemented | 睡眠 Tab 标题区打开记录；可回看历史报告 |
| P0-07 呼吸 | 4-7-8 放松 | lib/features/breath/breath_controller.dart | test/breath_controller_test.dart | implemented | 首页「呼吸练习」进入引导页 |
| P0-08 订阅 | 付费墙骨架 | — | — | deferred | StoreKit 与权益校验下一迭代 |
| P0-09 权限与隐私 | 设置与声明入口 | lib/features/settings/pages/settings_sheet.dart | — | implemented | 头像入口打开设置 sheet |
| P0-10 游客模式 | 无注册完成闭环 | lib/data/sleep_repository_impl.dart | — | implemented | 默认游客，无强制登录 |

## Tab 映射（松息 PRD → healing_tabs 四 Tab）

| 松息页面 | healing_tabs |
|---|---|
| TAB-TONIGHT 今晚 | 首页 |
| TAB-SOUNDS 声音 | 声音 |
| TAB-SLEEP 睡眠 | 睡眠 |
| 冥想/呼吸课 | 冥想 + 呼吸 feature |
| TAB-PROFILE 我的 | 顶栏头像 → 设置 sheet |
