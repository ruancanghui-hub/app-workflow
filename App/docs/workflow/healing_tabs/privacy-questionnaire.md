# Privacy Questionnaire — healing_tabs

与 App Store Connect「App 隐私」及 PRD 数据章节对齐。

## 数据收集摘要

| 数据类型 | 是否收集 | 用途 | 是否关联用户 | 是否用于追踪 |
|----------|----------|------|--------------|--------------|
| 联系信息 | 否 | — | — | 否 |
| 健康与健身 | 否（MVP） | 睡眠会话时长仅存本机，不上传 | — | 否 |
| 使用数据 | 否（MVP） | Firebase 未配置；无分析上报 | — | 否 |
| 诊断 | 否 | 非医疗产品 | — | 否 |
| 用户内容 | 否 | 无账号体系 | — | 否 |
| 标识符 | 否 | 无广告 ID / 无第三方追踪 | — | 否 |

**App Store Connect 隐私标签建议**：

- 数据不收集（Data Not Collected）— 若确认 Firebase 保持 `FIREBASE_CONFIGURED=false` 且无其他 SDK 上报
- 或「不关联身份的诊断/使用数据」— 若后续启用崩溃采集需重新评估

## 本地存储（设备内，非上传）

| 数据 | 存储 | 说明 |
|------|------|------|
| 睡眠会话记录 | SharedPreferences | 开始/结束时间、时长、主观评分 |
| 声景收藏 | SharedPreferences | 收藏 ID 列表 |
| 应用设置 | SharedPreferences | 游客模式、通知开关偏好 |
| 音频缓存 | 系统临时目录 | 流媒体缓冲，非持久下载队列 |

## 权限（Info.plist）

| 权限键 | 用途文案 | 触发时机 | MVP 状态 |
|--------|----------|----------|----------|
| `UIBackgroundModes: audio` | 伴睡播放可在后台继续 | 开始播放声景 | 已声明 |
| `NSUserNotificationsUsageDescription` | 轻唤醒与睡眠提醒 | 用户开启通知 | **未实现**（defer MVP+1） |
| `NSMicrophoneUsageDescription` | 伴睡播放音频会话管理；不录制不上传 | SDK 引用麦克风 API | **已声明** |
| `NSAppTransportSecurity` | 音频 CDN HTTP 例外 | 拉取远程声景 | 已配置域名例外 |

## 第三方 SDK

| SDK | 数据 | 隐私政策链接 | MVP 状态 |
|-----|------|--------------|----------|
| just_audio | 无用户数据；仅播放音频 | https://pub.dev/packages/just_audio | 使用中 |
| audio_session | 无用户数据 | https://pub.dev/packages/audio_session | 使用中 |
| dio | 网络请求元数据（声景列表 URL） | https://pub.dev/packages/dio | 使用中 |
| shared_preferences | 本机 KV | https://pub.dev/packages/shared_preferences | 使用中 |
| firebase_* | 分析/崩溃/远程配置 | https://firebase.google.com/support/privacy | **未启用** |

## 网络

- 声景目录 API：`GET {SOUND_CDN_BASE_URL}/api/list`
- 音频文件：从配置的 CDN 服务器流式播放（当前 `http://139.199.211.157:8080`）
- 不向第三方出售或共享用户数据

## 用户权利

- 删除账号/数据路径: 卸载 App 即清除本机全部数据；设置内无账号体系
- 隐私政策 URL: https://healingtabs.example/privacy（**提审前替换为可访问正式 URL**）
- 支持邮箱: support@healingtabs.example（**提审前替换**）

App 内入口：设置 → 隐私说明（弹窗摘要，与本文档一致）

## 合规声明

- [x] 文案与 App 内实际行为一致
- [x] 健康类未声称医疗诊断
- [x] 未成年人相关已按 PRD 处理或排除（17+ 分级，无儿童模式）

**privacy_gate**: PASS
