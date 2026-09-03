# 云遥 (healing_tabs)

Flutter 实例，基于 `output/brand-ip/healing_tabs` 四 Tab 视觉契约。

## 运行

### 一键启动到 Android 真机（推荐）

```bash
cd app-workflow/App/apps/healing_tabs
./scripts/run_android.sh
```

指定设备 ID（例如 RMX3700）：

```bash
./scripts/run_android.sh 4a2f2e04
```

### Android（手动命令）

```bash
cd app-workflow/App/apps/healing_tabs
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json -d <device_id>
```

示例（你的 RMX3700）：

```bash
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json -d 4a2f2e04
```

> **注意**：不要省略 `--flavor dev`，模板使用 dev/prod 双变体。  
> 若 Gradle 报 TLS / 下载失败，重试一次；项目已配置阿里云 Maven 镜像。

### iOS

```bash
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
```

首次需在 Xcode 复制 `dev`/`prod` scheme（见 `ios/FLAVORS.md`）。

## 结构

| 路径 | 说明 |
|---|---|
| `lib/features/root_shell/` | 四 Tab 根壳与底栏 |
| `lib/features/tabs/` | 各 Tab 页面（坐标来自 design-system-profile JSON） |
| `assets/images/<tab>/` | 从 `05-ui-assets` 复制的切图 |
| `.scratch/云遥/feature-checklist.md` | Phase 5 功能清单 |

## 设计基准

- 画布：941 × 1672
- JSON：`output/brand-ip/healing_tabs/04-core-tab-ui/design-system-profile-*.json`
- HTML 对照：`output/brand-ip/healing_tabs/06_asset_ui/`

## 验证

```bash
dart analyze lib test
flutter test
```
