# Healing Tabs — Asset UI Prototype

将 `04-core-tab-ui` 视觉契约与 `05-ui-assets` 切图资源合成为可点击 HTML 原型的领域词汇。

## Language

**视觉契约（Visual Contract）**:
`04-core-tab-ui/` 中已 QA 通过的整页参考图（941×1672），定义布局、文案与激活态，是 1:1 还原的比对基准。
_Avoid_: 骨架图、设计稿、mockup（当指代未锁定的方向稿时）

**切图资源（UI Assets）**:
`05-ui-assets/<tab>/` 下按语义分组的可落代码 PNG（backgrounds、feature_art、nav_icons、status、ui_controls）及 `manifest.json`。
_Avoid_: 切图、素材包、红框图（当指代标注过程而非交付物时）

**资产合成原型（Asset UI Prototype）**:
`06_asset_ui/` 中用 HTML/CSS 将切图资源按视觉契约坐标叠放、文案用可编辑文本层实现的本地可点击原型。
_Avoid_: 低保真线框、CDB 语义原型（当指代非资产驱动的实现时）

**根 Tab（Root Tab）**:
底部固定四项导航：`首页`、`睡眠`、`冥想`、`声音`；顺序不可变，仅激活态高亮变化。
_Avoid_: 主 Tab、底栏、一级页面

**激活态（Active State）**:
当前根 Tab 在底栏中的高亮样式；每个 Tab 页使用本页 `nav_icons/` 中对应图标资源。
_Avoid_: 选中态、current tab

**设计坐标系（Design Canvas）**:
以 941×1672 为基准的绝对定位单位；原型通过 CSS `transform: scale()` 缩放到设备视口。
_Avoid_: 逻辑像素、pt、dp

**语义角色（Source Role）**:
`manifest.json` 中 `source_role` 字段，标识素材在页面中的用途（如 `nav_sleep`、`background_home`）。
_Avoid_: 文件名、图层名

## Locked decisions (2026-08-29)

| 决策 | 选择 |
| --- | --- |
| 精度目标 | 叠对照验收（~40% 透明度叠图；玻璃态/波形为 CSS 近似） |
| 文案策略 | HTML 文本层；切图仅用于图标与背景 |
| SKILL 范围 | 项目级 `03_UI_UX/composing-asset-ui-prototype/` |
| 流水线角色 | Phase 2c 桥接包；完整交互文档走 Phase 3 |
