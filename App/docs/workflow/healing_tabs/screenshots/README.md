# App Store Screenshots — healing_tabs

提审前用 **真机或 Simulator** 截取，替换本目录占位说明。

## 规格

| 设备 | 分辨率 | 至少张数 |
|------|--------|----------|
| iPhone 6.7" (15 Pro Max) | 1290 × 2796 | 3 |
| iPhone 6.5" (11 Pro Max) | 1242 × 2688 | 3 |

## 主路径场景

1. `01-home.png` — 首页四 Tab
2. `02-player.png` — 声景播放中
3. `03-sleep-report.png` — 睡眠报告
4. `04-breath.png` — 呼吸引导
5. `05-sound-library.png` — 声景库
6. `06-settings.png` — 设置与隐私说明

## 捕获命令（Simulator）

```bash
# 启动 prod 构建
cd App/apps/healing_tabs
flutter run --flavor prod --dart-define-from-file=dart_defines.prod.json

# 另开终端：列出设备并截图
xcrun simctl list devices | grep Booted
xcrun simctl io booted screenshot screenshots/01-home.png
```

## 设计参考（非商店素材）

视觉契约见 `output/brand-ip/healing_tabs/04-core-tab-ui/`。

**勿**直接上传设计稿 PNG — 必须与当前 App UI 一致。
