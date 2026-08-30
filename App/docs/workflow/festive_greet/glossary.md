# 节庆祝福 — 领域词汇

## Language

**节日（Festival）**:
农历/公历节庆节点（春节、中秋、端午等），驱动模板推荐与文案语气。
_Avoid_: 活动、Campaign（当指运营活动时）

**祝福模板（Greeting Template）**:
预设计的贺卡版式 + 默认文案 + 可替换插图/背景，用户在其上编辑。
_Avoid_: 海报、H5（当指 App 内实体时）

**祝福语（Greeting Message）**:
用户可编辑的祝词正文，支持多行与署名。
_Avoid_: 短信、推送文案（当指编辑区内容时）

**贺卡预览（Card Preview）**:
编辑完成后的全屏预览态，可保存图片或调起系统分享。
_Avoid_: 详情页

**我的贺卡（Saved Card）**:
本地保存的已生成贺卡记录（缩略图 + 创建时间 + 节日标签）。
_Avoid_: 收藏、历史（泛称时）

**游客模式（Guest Mode）**:
无需注册即可走完「选模板 → 编辑 → 预览 → 保存/分享」闭环。
_Avoid_: 匿名用户

**分享出口（Share Channel）**:
系统分享面板（微信/短信/保存相册等），MVP 不内置 IM SDK。
_Avoid_: 社交feed

## Store vs Engineering

| 工程 slug | 商店展示名 | Bundle ID |
|-----------|------------|-------------|
| `festive_greet` | 节庆祝福（待定） | `com.nightelf.festivegreet` |
