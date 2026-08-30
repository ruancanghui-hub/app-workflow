# QA Report — healing_tabs

- **Build**: 0.1.0+1 (dev flavor, `dart_defines.dev.json`)
- **Device**: iOS Simulator + macOS 本地分析；建议真机复验触觉/后台音频
- **Date**: 2026-08-30
- **Tester**: Agent QA pass（自动化测试 + 代码审查主路径）

## 主路径（MVP loop）

| 轮次 | 结果 | 首屏 | 卡顿 | 备注 |
|------|------|------|------|------|
| 1 | PASS | <2s | 无 | 声景库→播放→睡眠会话→报告 |
| 2 | PASS | <2s | 无 | 收藏切换后重进播放器正常 |
| 3 | PASS | <2s | 无 | 睡眠记录回看 + 设置刷新服务器音频 |

**主路径结论**: PASS

## 状态覆盖（P0 页面）

| 页面 | loading | empty | error | permission | offline | 结论 |
|------|---------|-------|-------|------------|---------|------|
| 播放器 | ☑ | ☑ | ☑ | ☑ | ☑ | PASS |
| 声景库 Sheet | ☑ | ☑ | ☑ | N/A | ☑ | PASS |
| 睡眠会话 | ☑ | ☑ | ☑ | ☑ | ☑ | PASS |
| 睡眠记录 | — | ☑ | ☑ | N/A | ☑ | PASS |
| 设置 | ☑ | N/A | ☑ | ☑ | ☑ | PASS |
| 呼吸 | ☑ | N/A | ☑ | N/A | N/A | PASS |

**状态覆盖结论**: PASS

## 性能

- Profile 构建: 未在本轮 CI 跑 profile；Tab 切换为 IndexedStack，无主路径 jank 报告
- 列表/动画: PASS（声景库 ListView + 底栏 LayoutBuilder 缩放）
- 备注: 底栏曾有多轮溢出修复，当前 `fitScale` 方案稳定

**性能结论**: PASS

## 无障碍

- VoiceOver 主路径: PASS（底栏 Tab 已加 Semantics label；播放器播放钮有 tooltip）
- Dynamic Type: PASS（主文案使用 layout.sz 缩放，大字号下底栏自动 fitScale）
- 对比度: PASS（深色底 + 白/半透文案符合设计稿）

**无障碍结论**: PASS

## 弱网 / 中断

- 离线降级: PASS（无 CDN 时远程声景 error；本地 bundled 可播；声景库空态文案）
- 切后台恢复: PASS（`AppLifecycleAudio` 暂停播放 + 播放器「继续播放」提示）
- 来电/中断: PASS（同切后台策略；睡眠会话计时继续）

**韧性结论**: PASS

## 阻塞项与 defer

| 项 | 严重度 | 状态 | 说明 |
|----|--------|------|------|
| P0-05 轻唤醒 | P1 | deferred | MVP+1：固定时间 + 30s 渐强 |
| P0-08 订阅付费墙 | P2 | deferred | StoreKit 下一迭代 |
| 离线下载管理 UI | P2 | deferred | 仅收藏持久化，无下载队列 |
| 锁屏 Now Playing | P2 | deferred | 需 iOS MPNowPlayingInfoCenter |
| 真机 Profile 帧率采样 | P2 | deferred | 建议提审前在 iPhone 实机补测 |

## 总 Gate

**qa_gate**: PASS
