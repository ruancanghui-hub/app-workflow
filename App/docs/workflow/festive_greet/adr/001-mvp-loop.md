# ADR 001 — MVP 闭环

## 状态

已接受 — 2026-08-30

## 背景

节庆祝福 App 需在 TestFlight 验证「用户能否在 5 分钟内做出一张可分享的节日贺卡」，且不依赖账号与订阅。

## 决策

**MVP 闭环**：选节日 → 选模板 → 编辑祝福语 → 预览 → 保存到相册 / 系统分享。

- 游客模式默认开启，无注册墙
- 订阅（StoreKit）defer 至 MVP+1
- iOS 优先；Bundle `com.nightelf.festivegreet`
- 发布路径复用 `healing_tabs` 验证过的本机签名 + `upload_app_store.sh` 流水线

## 否决条件

- 无法离线使用已缓存模板完播制作流程
- 保存/分享前强制登录或付费
- 使用未授权节日素材或商标元素
