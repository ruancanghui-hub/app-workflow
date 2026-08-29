# Healing Tabs — 资产合成原型

将 `05-ui-assets/` 切图按 `04-core-tab-ui/` 视觉契约 **叠对照 1:1** 合成的可点击 HTML 原型。

> **范围**：Phase 2c 桥接包 — 验证切图可用性。完整交互文档、追溯矩阵走 Phase 3（`creating-app-prototypes`）。

## 锁定决策

| 项 | 选择 |
| --- | --- |
| 精度 | 叠对照验收（背景/图标/文案对齐；玻璃态为 CSS 近似） |
| 文案 | HTML 文本；PNG 仅用于图标与背景 |
| 范围 | 不含交互状态目录、CDB 导出 |

## 打开方式

**推荐**（JSON 布局需 fetch 加载）：

```bash
cd app-workflow/output/brand-ip/healing_tabs/06_asset_ui
python3 -m http.server 8765
# 浏览器访问 http://localhost:8765
```

或直接 `open index.html`（部分浏览器可能因 `file://` 限制无法加载 `04-core-tab-ui/*.json`）。

## 文件

| 文件 | 用途 |
| --- | --- |
| `index.html` | 四 Tab 页面结构与 `data-codex-id` / `data-layout-slot` 节点 |
| `styles.css` | 玻璃态、排版与组件视觉样式 |
| `apply-layout.js` | 从 `04-core-tab-ui/design-system-profile-*.json` 应用像素坐标 |
| `app.js` | Tab 切换与参考图叠对照 |
| `layout-spec.json` | 指向各 Tab 设计系统 profile 的 manifest |
| `visual-analysis.md` | Phase 0b 视觉分析（组件/颜色/排版/导航图） |

设计系统 profile（`04-core-tab-ui/`）：

- `design-system-shared.json` — 画布、底栏、排版 scale
- `design-system-profile-{home,sleep,meditation,sound}.json` — 各 Tab 视觉风格 + `layout_slots`

叠对照参考图直接引用 `../04-core-tab-ui/`（不复制副本）。

## 对照验收

1. 勾选右上角「对照参考图」，调节透明度至约 40%。
2. 逐 Tab 检查：背景、图标、文案位置、底栏激活态。
3. 与 `qa-report.md` 中 PASS 的四张参考图比对。
4. 已知 CSS 近似：玻璃模糊、声波波形、标签 pill 样式。

## 验证脚本

```bash
python3 app-workflow/03_UI_UX/composing-asset-ui-prototype/scripts/validate_asset_ui_prototype.py \
  app-workflow/output/brand-ip/healing_tabs
```

## 依赖

- 素材路径：`../05-ui-assets/<tab>/`
- 不依赖构建工具或网络 CDN。
