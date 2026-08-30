# 节庆祝福 MVP 范围

- 产品名：节庆祝福
- 模式：智能模式
- 平台：iOS 优先（首发 iPhone）
- 目标用户：18+ 需要在节庆节点快速制作祝福贺卡的中文用户
- 商业策略：MVP 全免费游客体验；订阅解锁高级模板 defer 至 MVP+1
- 版本：V1.0
- 日期：2026-08-30

## 1. 验证假设

在 4 周内，若目标用户能在 5 分钟内用节庆祝福完成「选模板 → 写祝词 → 保存或分享」且无需注册，则节庆轻工具假设成立，可再投入订阅与远程模板。

## 2. 目标用户

首发：iPhone、iOS 16+、18+、中文环境、节庆前一周活跃。排除：需团队协作批量的 B 端用户（P2）。

## 3. In Scope

| 闭环步骤 | 最小可用形态 | 验收结果 |
|---|---|---|
| 发现节日 | 首页推荐 + 模板 Tab 分类 | 可进入模板详情 |
| 选模板 | ≥6 套 bundled 静态模板 | 可预览并选中 |
| 编辑祝词 | 多行文案 + 署名 | 预览实时更新 |
| 预览导出 | 全屏预览 + PNG | 清晰无裁切 |
| 保存/分享 | 相册 + 系统分享 | 至少一种成功 |
| 我的贺卡 | 本地历史列表 | 可再次打开 |
| 设置 | 游客、隐私说明 | 无注册墙 |
| 发布 | TestFlight build | upload 脚本 PASS |

## 4. Out of Scope

- StoreKit 订阅与付费墙（defer MVP+1）  
- 账号登录与云同步  
- 微信 SDK 内置发送  
- AI 生成祝词  
- 视频/动效贺卡  
- Android 首发  
- 远程模板 CDN（P1；MVP 仅 bundled）

## 5. 最小内容与数据对象

### 5.1 首发内容

- 原创贺卡模板 ≥6（春节≥2、中秋≥2、通用≥2）  
- 默认祝福语库每节日 ≥3 条  
- App Icon + 启动图（Phase 2 品牌 IP）

### 5.2 最小数据对象

GreetingTemplate、GreetingMessage、RenderedCard、SavedCard、AppSettings。

### 5.3 工程标识

- slug: `festive_greet`  
- Bundle: `com.nightelf.festivegreet`  
- 输出: `App/apps/festive_greet`

## 6. 关键页面

欢迎（可选）→ 首页 → 模板库 → 编辑器 → 预览 → 导出成功；我的 → 贺卡详情；设置。

## 7. 验收标准

### 7.1 产品闭环

新用户 10 分钟内可不注册完成一张贺卡并保存或分享。

### 7.2 稳定性

连续制作 10 张无崩溃；相册权限流程符合审核。

### 7.3 发布

`./scripts/upload_app_store.sh` 上传 TestFlight；隐私问卷与 submission 文档齐全。

## 8. 工作包

| 包 | 阶段 | 产出 |
|---|---|---|
| W1 PRD | Phase 1 | 五件套 + gate PASS |
| W2 品牌 IP | Phase 2 | Icon、Tab UI、模板视觉 |
| W3 原型 | Phase 3 | 追溯矩阵 + 交互说明 |
| W4 脚手架 | Phase 4 | `apps/festive_greet` |
| W5 功能 | Phase 5 | 编辑/预览/导出 |
| W6 QA | Phase 6 | qa-report |
| W7 上架 | Phase 7 | TestFlight |

## 9. 灰度发布

内部 TestFlight → 亲友 10 人 smoke → 收集导出成功率。

## 10. 后续扩张

P1 订阅模板、远程 CDN、登录同步；P2 动效、视频、小组件节日提醒。

## 11. 发布否决条件

- 模板版权不清  
- 主路径强制登录或付费  
- 无法上传 TestFlight  
- 相册权限无用途说明
