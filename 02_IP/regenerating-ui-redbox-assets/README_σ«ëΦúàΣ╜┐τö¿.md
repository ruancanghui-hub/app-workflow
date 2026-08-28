# 安装与使用

这个 Skill 用于：上传一张带红框标注的 UI 图后，自动识别需要重生成的图标/插画，并按组输出独立 PNG；如果用户要求背景，也单独生成无 UI 的背景图，最后打包 ZIP。

## 安装
将整个 `ui-redbox-assets-skill` 目录放到支持 Agent Skills 的 skills 目录中，例如：

- `~/.agents/skills/regenerating-ui-redbox-assets/`

目录中的 `SKILL.md` 必须保留。

## 下次怎么说
上传标红框截图后直接说：

> 按 regenerating-ui-redbox-assets 处理：红框里的资源全部单独重生成，背景也单独生成，按组命名并打包 ZIP。

也可以简单说：

> 按上次的红框资源 Skill 处理。

## 默认分组
- `ui_controls`：搜索、Plus、播放、关闭等
- `status`：状态表情/徽标
- `feature_art`：叶子、海浪、书本、月亮等内容插画
- `nav_icons`：首页、睡眠、冥想、声音、我的
- `backgrounds`：整页无 UI 背景
