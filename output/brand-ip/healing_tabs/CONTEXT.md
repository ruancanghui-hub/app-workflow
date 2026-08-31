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
以 941×1672 为基准的绝对定位单位；Flutter 通过 `HealingLayout` 按屏宽等比缩放。
_Avoid_: 逻辑像素、pt、dp

**声景（Sound Asset）**:
可播放的伴睡音频条目，含标题、标签、免费/付费标记与本地资源引用。
_Avoid_: 曲目、白噪音（当指代具体目录实体时）

**睡眠会话（Sleep Session）**:
用户从播放器或睡眠 Tab 发起的单次在床记录，含开始/结束时刻、关联声景与主观评分。
_Avoid_: 睡眠记录、监测任务

**播放状态（Player Status）**:
声景播放器生命周期：`idle` → `loading` → `playing`/`paused` → `error`；由 `just_audio` 驱动真实音频，非模拟计时。
_Avoid_: 播放中、暂停中（当指代状态机枚举时）

**声景来源（Sound Playback Source）**:
`bundled` 指包内 `assets/sounds/` 本地录音；`remote` 指网站 CDN（`SOUND_CDN_BASE_URL` + 相对路径）；目录可通过 `/api/list` 同步服务器音频总数。
_Avoid_: 在线音乐、流媒体（当指代具体目录实体时）

**声景目录（Sound Catalog）**:
App 内可播放的声景列表；启动时通过 `/api/list` 与静态元数据合并，服务器条目优先远程播放。
_Avoid_: 播放列表、歌单（当指代疗愈场景时）

**睡眠记录（Sleep History）**:
已结束会话的本地列表，含开始时间、在床时长与主观评分；从睡眠 Tab 进入。
_Avoid_: 睡眠日记、健康档案

**游客模式（Guest Mode）**:
默认无需注册即可走完「选声景→睡眠会话→报告」闭环；设置中可显式切换。
_Avoid_: 匿名用户、未登录

**语义角色（Source Role）**:
`manifest.json` 中 `source_role` 字段，标识素材在页面中的用途（如 `nav_sleep`、`background_home`）。
_Avoid_: 文件名、图层名

**播放场景（Playback Scenario）**:
共享播放器上的业务上下文：`sleep`（睡眠伴睡）或 `meditation`（冥想练习）。决定结束页、是否显示睡眠定时器/呼吸引导叠加层。
_Avoid_: 模式、场景切换（泛指 Tab 时）

**冥想练习（Meditation Practice）**:
单次有时长目标的练习记录，含白噪音底噪与可选情绪反馈；V1 无系列课/无语音引导。
_Avoid_: 冥想课程、冥想课

**练习小结（Practice Summary）**:
冥想练习结束后的反馈页：展示实际时长与 3 选 1 情绪，无日历 Streak。
_Avoid_: 打卡页、完成页（当指代分享卡时）

**睡眠定时器（Sleep Timer）**:
睡眠场景下到点渐隐停播的倒计时；到点只停音频，不自动结束睡眠会话。
_Avoid_: 闹钟、轻唤醒

## Locked decisions (2026-08-29)

| 决策 | 选择 |
| --- | --- |
| 精度目标 | 叠对照验收（~40% 透明度叠图；玻璃态/波形为 CSS 近似） |
| 文案策略 | HTML 文本层；切图仅用于图标与背景 |
| SKILL 范围 | 项目级 `03_UI_UX/composing-asset-ui-prototype/` |
| 流水线角色 | Phase 2c 桥接包；完整交互文档走 Phase 3 |
