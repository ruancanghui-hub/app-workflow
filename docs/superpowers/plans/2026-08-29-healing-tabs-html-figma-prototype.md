# Healing Tabs HTML 与 Figma 导入稿 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从四 Tab 骨架页与切图资产交付像素画布固定的 HTML 原型和 Figma 可导入 SVG 屏幕稿。

**Architecture:** 复用已存在的资产合成 HTML 原型作为交互层和布局层；用布局 JSON 驱动 941 × 1672 坐标。每个 Figma SVG 由参考骨架 PNG 转换，作为一个尺寸固定的、本地可导入的屏幕设计稿。

**Tech Stack:** 静态 HTML/CSS/JavaScript、12ui CLI SVG 转换、PNG 资产、SVG。

**Spec:** `docs/superpowers/specs/2026-08-29-healing-tabs-html-figma-design.md`

## Global Constraints

- 四个目标画布均为 941 × 1672。
- 原型只以 `05-ui-assets` 作为页面视觉资产；参考骨架 PNG 仅用于叠图和 Figma 导入稿。
- 不修改任何 `05-ui-assets/backgrounds/` 图像。
- Figma 交付为本地 SVG，不创建云端 Figma 文档。

---

### Task 1: 发布原型副本

**Files:**
- Create: `output/brand-ip/healing_tabs/07_html_figma_prototype/prototype/`
- Source: `output/brand-ip/healing_tabs/06_asset_ui/`

- [x] **Step 1: Verify the existing prototype contract**

Run: `python3 03_UI_UX/composing-asset-ui-prototype/scripts/validate_asset_ui_prototype.py output/brand-ip/healing_tabs`

Expected: the four source screens, asset folders, and layout profile references are valid.

- [x] **Step 2: Publish the static prototype without rewriting its asset references**

Copy the existing `06_asset_ui` static files into the `prototype/` delivery folder, preserving their relative `../04-core-tab-ui` and `../05-ui-assets` references through a delivery-relative asset link.

- [x] **Step 3: Verify the production copy**

Run a local static server in the delivery root and confirm that HTML, CSS, JavaScript, layout JSON, and all four tab asset paths return successfully.

### Task 2: Export Figma import screens

**Files:**
- Create: `output/brand-ip/healing_tabs/07_html_figma_prototype/figma-import/{home,sleep,meditation,sound}.svg`

- [x] **Step 1: Convert each source skeleton page to SVG**

Run the tested local fallback: `python3 02_IP/converting-sliced-ui-to-html-figma/scripts/export_figma_svg.py <04-core-tab-ui/page.png> <figma-import/page.svg> 941 1672`.

Expected: four SVG design files with a 941 × 1672 root canvas.

- [x] **Step 2: Verify SVG dimensions and payloads**

Run a metadata script that checks SVG `width`/`height` or `viewBox`, and confirms every expected named screen exists.

### Task 3: Document the delivery

**Files:**
- Create: `output/brand-ip/healing_tabs/07_html_figma_prototype/README.md`

- [x] **Step 1: Write launch and import instructions**

Include the local HTTP server command, tab behavior, Figma drag-and-drop import, and overlay comparison steps.

- [x] **Step 2: Verify file links**

Run an existence check for every referenced source asset, output SVG, and prototype entry point.

### Task 4: Create the reusable skill

**Files:**
- Create: `02_IP/converting-sliced-ui-to-html-figma/SKILL.md`

- [x] **Step 1: Capture pressure scenarios**

Test the skill against: a page with no layout JSON, a multi-tab app with inconsistent navigation, and a request for cloud Figma without a connector.

- [x] **Step 2: Write the minimal reusable workflow**

Cover input inventory, fixed-canvas HTML composition, SVG Figma export, asset/reference boundaries, and verification.

- [x] **Step 3: Re-run the pressure scenarios**

Confirm the skill selects the correct fallback for each scenario without inventing assets or claiming cloud Figma export.
