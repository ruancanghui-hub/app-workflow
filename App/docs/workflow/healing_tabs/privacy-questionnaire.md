# Privacy Questionnaire — healing_tabs（云遥）

与 App Store Connect「App 隐私」及应用内《隐私政策》对齐。

## 数据收集摘要

| 数据类型 | 是否收集 | 用途 | 是否关联用户 | 是否用于追踪 |
|----------|----------|------|--------------|--------------|
| 联系信息 | 否 | — | — | 否 |
| 健康与健身 | 否（仅本机处理，不传出设备，按 Apple 定义不属于「收集」） | Apple 健康只读的休息摘要/睡眠阶段/心率，仅本机展示；不上传、不用于广告 | — | 否 |
| 使用数据 | 是（同意后） | Firebase Analytics 产品改进（同意后才 `initialize`） | 可能通过安装级标识 | 否（非跨 App 广告追踪声明；广告见下） |
| 诊断 | 是（同意后） | Firebase Crashlytics 稳定性（同意后才启用） | 可能 | 否 |
| 用户内容 | 否 | 无 UGC 上传 | — | 否 |
| 标识符 | 是（同意后，广告相关） | AdMob 广告投放；本机安装级 ID 仅本地 | 广告 ID 由系统/SDK 管理 | 视 ATT 授权：用于广告个性化时按「追踪」披露 |

**App Store Connect 隐私标签建议**：

- 勾选：诊断、产品交互/使用数据、设备 ID（广告）
- 不勾选健康与健身：HealthKit 数据只在本机展示、不传出设备
- 第三方：Google Firebase、Google AdMob
- 追踪：若使用 IDFA 做广告个性化，按 ATT 实际授权勾选「用于追踪的数据」

## 本地存储（设备内）

| 数据 | 存储 | 说明 |
|------|------|------|
| 本机云遥账号 | SharedPreferences | 安装级 ID、昵称 |
| 睡眠会话 / 历史 | SharedPreferences | 监测会话与报告字段 |
| 声景收藏 | SharedPreferences | 收藏 ID |
| Apple 健康授权标记 | SharedPreferences | 是否已请求过读权限 |
| 冥想播放时间窗 | SharedPreferences | 起止时刻与内容元数据（不含心率数值） |
| 隐私同意 | SharedPreferences | `privacy_consent_v1` |
| 应用设置 | SharedPreferences | 通知等 |

用户可在「我的 → 删除本机数据」清除上述数据并重置同意。

## 权限（Info.plist）

| 权限键 | 用途文案 | 触发时机 |
|--------|----------|----------|
| `UIBackgroundModes: audio` | 伴睡/播放后台续播 | 开始播放 |
| `NSHealthShareUsageDescription` | 只读 Apple 健康休息/心率 | 休息 Tab「连接 Apple 健康」 |
| `NSHealthUpdateUsageDescription` | 框架要求；当前不写入 | 打包校验 |
| `NSUserTrackingUsageDescription` | 相关广告 | ATT 弹窗（同意广告后） |
| `NSMicrophoneUsageDescription` | 音频会话管理（不录音） | 音频 SDK 链接要求，即使不录音也需声明 |
| `NSAppleMusicUsageDescription` | 系统媒体/锁屏控制 | 音频 SDK 链接要求，不读取资料库 |
| `NSSpeechRecognitionUsageDescription` | 系统音频框架声明 | 音频 SDK 链接要求，当前不使用语音识别 |
| `ITSAppUsesNonExemptEncryption` | false | 仅标准 TLS |
| `GADApplicationIdentifier` | AdMob App ID | SDK |
| `SKAdNetworkItems` | 广告归因 | AdMob |

> ASC ITMS-90683：只要二进制链接了敏感 API，就必须有 purpose string，与业务是否调用无关。

## 第三方 SDK

| SDK | 数据 | 隐私政策 | 状态 |
|-----|------|----------|------|
| just_audio / audio_session / audio_service | 播放会话 | pub.dev | 使用中 |
| dio | 声景列表网络请求 | pub.dev | 使用中 |
| shared_preferences | 本机 KV | pub.dev | 使用中 |
| google_mobile_ads | 广告 / UMP | https://policies.google.com/privacy | 使用中（同意后初始化） |
| firebase_analytics / crashlytics / remote_config | 使用与诊断 | https://firebase.google.com/support/privacy | 已配置时启用 |
| health | Apple HealthKit 只读 | pub.dev | 使用中（仅 iOS） |
| permission_handler | 权限请求 | pub.dev | 使用中 |

## 网络

- 声景目录 / 音频 CDN（可能含 HTTP 例外域名，计划迁 HTTPS）
- Firebase / AdMob Google 服务
- 不向第三方出售用户数据

## 用户权利

- 删除本机数据：我的 → 设置与合规 → 删除本机数据
- 隐私政策 / 用户协议：应用内完整正文 + 公网
  - 隐私：https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html
  - 协议：https://ruancanghui-hub.github.io/app-workflow/yunyao/terms.html
- 首次启动同意门：同意前不初始化广告 SDK

## 合规声明

- [x] 文案与 App 内实际行为一致（含广告、Firebase、Apple 健康数据）
- [x] 健康类未声称医疗诊断
- [x] 提供本机数据删除路径
- [x] 17+ / 非儿童面向

**privacy_gate**: READY（托管公网隐私政策 URL 并填入 ASC 后可标 PASS）
