# ADR-0001: 用 HTML 资产叠放实现 1:1 原型

## Status

Accepted (2026-08-29)

Locked decisions:
- Overlay QA at ~40% opacity (not pixel-perfect CSS)
- HTML text for labels; PNG for icons/backgrounds only
- Phase 2c bridge only; Phase 3 handles interaction specs

## Context

`05-ui-assets` 已产出按语义分组的 PNG 切图与 `manifest.json`，`04-core-tab-ui` 有四张已 QA 的 941×1672 视觉契约图。需要在 Phase 3 之前验证切图能否还原整页，并为 Flutter 实现提供坐标参考。

可选方案：

1. **整页 PNG 对照** — 仅展示参考图，不验证切图可用性。
2. **Figma 手工拼版** — 精度高但不可复现、难纳入 app-workflow 自动化。
3. **HTML/CSS 资产叠放** — 用相对路径引用切图，文本用可编辑 HTML，支持参考图半透明叠对照。

## Decision

采用 **HTML/CSS 资产叠放**，输出到 `06_asset_ui/`：

- 设计坐标系固定为 941×1672（与视觉契约一致）。
- 每 Tab 使用本页 `05-ui-assets/<tab>/` 资源；底栏激活态用该页 `nav_icons/`。
- 文案、标签等用 HTML 文本层（切图不含文字）。
- 玻璃容器用 CSS `backdrop-filter` 近似，不额外生成切图。
- 内置参考图叠对照开关，用于 1:1 验收。

## Consequences

**优点**

- 可本地打开、可点击切 Tab、可版本管理。
- 验证切图路径与 manifest 是否完整。
- `layout-spec.json` 可复用到 Flutter 坐标或下轮迭代。

**缺点**

- 玻璃态、波形等装饰与参考图存在 CSS 近似误差，需叠对照人工验收。
- 非 CDB/Figma 链路，不自动同步到设计工具。

## Alternatives considered

- **Flutter 直接实现**：过早，原型阶段需要更快迭代布局。
- **纯 CSS 无切图**：无法验证 `05-ui-assets` 交付质量。
