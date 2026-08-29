# Healing Tabs · HTML 原型与 Figma 导入稿

## 交付

- `prototype/index.html`：四 Tab 可点击 HTML 原型，画布固定 941 × 1672，按浏览器可用空间等比缩放。
- `figma-import/home.svg`、`sleep.svg`、`meditation.svg`、`sound.svg`：可直接拖入 Figma 的本地屏幕稿。

## 打开 HTML 原型

```bash
cd output/brand-ip/healing_tabs/07_html_figma_prototype
python3 -m http.server 8765
```

访问 `http://localhost:8765/prototype/`。底栏可切换四个页面；右上角的「对照参考图」可叠加骨架页进行校准。

## 导入 Figma

将 `figma-import/` 中任意 SVG 拖入 Figma 画布。每个文件都是自包含的 941 × 1672 设计稿，视觉与相应骨架 PNG 逐像素一致。

## 资产边界

HTML 页面内容来自 `05-ui-assets/`；`04-core-tab-ui/` 的 PNG 仅用于叠图对照和 Figma 屏幕导入稿。背景资源未重新生成或修改。
