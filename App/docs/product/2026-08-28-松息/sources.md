# 松息 来源

- 访问日期：2026-08-28
- 调研范围：潮汐 App Store/Play/官网协议；Apple 健康审核规则；睡眠麦克风方案公开文档（边界参考）

## 1. 来源表

| 页面标题 | URL | 来源类型 | 访问日期 | 支持的结论 |
|---|---|---|---|---|
| 潮汐 App Store 产品页 | https://apps.apple.com/cn/app/id1077776989 | APP_STORE | 2026-08-28 | 主模块：冥想、白噪音、睡眠故事、睡眠监测与报告、轻唤醒、番茄专注、呼吸、离线、小组件/系统表面、Watch、IAP 订阅；iOS 16+；健康健美 |
| 潮汐 Google Play | https://play.google.com/store/apps/details?id=io.moreless.tide | APP_STORE | 2026-08-28 | Android 侧同样强调睡眠/小憩、专注计时、呼吸、声景与故事（本项目 Android 后置） |
| 潮汐会员及续费协议 | https://tide.fm/pages/general/terms-of-member/zh-hans | OFFICIAL_SITE | 2026-08-28 | Freemium：会员含声音场景、冥想课等权益表述 |
| 潮汐隐私政策 | https://tide.fm/terms/zh-Hans/privacy.html | OFFICIAL_SITE | 2026-08-28 | 竞品收集类别对照（位置、健康、购买、标识符等）；松息隐私文案需自制 |
| App Store Review Guidelines（Health） | https://developer.apple.com/app-store/review/guidelines/#health-and-health-research | PLATFORM_DOC | 2026-08-28 | 1.4.1 准确率披露与传感器限制；5.1.3 健康数据禁广告定向等 |
| Sleep Cycle SDK iOS（麦克风睡眠） | https://sdk.sleepcycle.com/en/ios | PLATFORM_DOC | 2026-08-28 | 麦克风睡眠分析需 `NSMicrophoneUsageDescription` 与后台 audio 模式（R&D 可行性参考，非采用承诺） |

## 2. 竞品自述与独立事实边界

以下仅来自潮汐营销/商店文案，**未独立验证**：全球用户量与评分含义、机器学习睡眠分期准确性、梦话鼾声识别效果、呼吸异常与低氧风险能力、HRV 压力洞察有效性、「治疗」类用户评语气。松息不得照搬为自身效果主张。

## 3. 未核实信息

- 潮汐客户端信息架构的像素级 Tab 命名与付费墙细节（未安装取证）。影响：IA 为范式对齐而非 UI 复刻。  
- 麦克风方案自研 vs 第三方最终选型。影响：算法监测留在 R&D。  
- 中国大陆上架主体、ICP/SDK 清单与最终年龄分级。影响：法务门在商店阶段关闭。  
- 用户是否接受「功能对齐但品牌/内容全原创」而非视觉复刻。影响：见 assumptions 待确认。

## 4. 检索停止条件

已覆盖竞品一级模块、订阅模式、iOS 优先边界，以及健康宣称/麦克风权限的平台约束；来源数在智能模式上限内。停止继续扩检索，缺口记入本节与 assumptions。
