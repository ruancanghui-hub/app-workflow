# Healing Tabs HTML 与 Figma 导入稿设计

## 目标

将 `output/brand-ip/healing_tabs/04-core-tab-ui/` 的四张骨架页和 `05-ui-assets/` 的页面资产交付为一个可点击、按 941 × 1672 画布呈现的 HTML 原型，以及四张可导入 Figma 的 SVG 屏幕稿。

## 输入与固定约束

- 参考画布固定为 941 × 1672；首页、睡眠、冥想、声音各一屏。
- HTML 保留 `05-ui-assets/<tab>/` 的背景、图标与控件，不将截图作为页面背景。
- 各 Tab 的坐标、字体角色、底栏次序与激活态以 `04-core-tab-ui/design-system-*.json` 为准。
- 导入 Figma 的 SVG 以对应骨架页 PNG 为唯一图像节点，尺寸与参考页一致；此选择保证视觉逐像素一致。
- 交付是本地 Figma 导入稿，不创建在线 Figma 文件或链接。

## 交付结构

`output/brand-ip/healing_tabs/07_html_figma_prototype/`

- `prototype/`：从现有资产合成原型发布的 1:1 可点击 HTML。
- `figma-import/`：`home.svg`、`sleep.svg`、`meditation.svg`、`sound.svg`，可直接拖入 Figma。
- `README.md`：启动原型、导入 Figma、叠图验收说明。

## 验收

1. HTML 原型具备四 Tab 点击切换；浏览器以 941 × 1672 缩放展示，不拉伸画布。
2. HTML 中的页面图像均来自 `05-ui-assets`；参考 PNG 仅允许在叠图对照层使用。
3. 每个 SVG 根画布为 941 × 1672，并呈现相应的 04-core-tab-ui 骨架页。
4. 交付目录包含四个 SVG、一个可运行原型与说明文件。
5. 新技能能指导后续项目从骨架 PNG、页面资产和布局配置产出同类 HTML 与本地 Figma 导入稿。
