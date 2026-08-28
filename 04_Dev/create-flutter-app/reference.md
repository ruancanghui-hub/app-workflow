# 模板实例 — 配置参考

## Firebase

1. 本地添加（勿提交）：
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - 可选：`flutterfire configure` 生成 `lib/firebase_options.dart`
2. 运行时必须：

```bash
flutter run --flavor dev \
  --dart-define=APP_VARIANT=dev \
  --dart-define=FIREBASE_CONFIGURED=true
```

未设 `FIREBASE_CONFIGURED=true` 时始终用假实现，不扫描 plist/json。

## dart-define 一览

| Define | 默认 | 用途 |
|--------|------|------|
| `APP_VARIANT` | `dev` | 与 `--flavor` 对齐：`dev` / `prod` |
| `APP_INSTANCE_ID` | 脚本写入 | 应用实例身份 |
| `APP_INSTANCE_NAME` | 脚本写入 | 展示名 |
| `OPS_CONSOLE_BASE_URL` | 空 | 运营台 API；空 = no-op |
| `FIREBASE_CONFIGURED` | `false` | 是否启用 Firebase 适配器 |

`dart_defines.dev.json` 示例：

```json
{
  "APP_VARIANT": "dev",
  "APP_INSTANCE_ID": "yunyao_sleep_v1",
  "APP_INSTANCE_NAME": "云遥睡眠",
  "FIREBASE_CONFIGURED": "false",
  "OPS_CONSOLE_BASE_URL": ""
}
```

prod 可另建 `dart_defines.prod.json`，`APP_VARIANT` 为 `prod`。

## iOS 构建变体

Flutter iOS 要求 scheme 名与 Android flavor 同名（`dev`、`prod`）。

一次性在 Xcode：

1. 打开 `ios/Runner.xcworkspace`
2. 复制 `Runner` scheme → 命名为 `dev`、`prod`
3. 可选：Run 配置指向 `Flutter/Dev.xcconfig` / `Flutter/Prod.xcconfig`

命令：

```bash
flutter run --flavor dev --dart-define=APP_VARIANT=dev
flutter run --flavor prod --dart-define=APP_VARIANT=prod
```

Android：`dev` flavor 的 applicationId 带 `.dev` 后缀。

## 运维底座端口

模板已注入薄接口 + 默认假实现：

- Analytics（行为埋点）
- RemoteConfig（远程配置 / 功能开关）
- CrashReporter（缺陷定位）

业务代码通过 GetX 取端口，不要直接依赖 Firebase SDK。

## 文档指针（模板仓内）

- `flutter-app-template/docs/firebase-and-secrets.md`
- `flutter-app-template/docs/ops-console-api.md`
- `flutter-app-template/template/ios/FLAVORS.md`
- `flutter-app-template/docs/flutter-create-template-conventions.md`

## 禁止

- 不要把业务代码写进 `flutter-app-template/template/`
- 不要用 `flutter create -t` 指向本仓路径（Flutter 3.x 不支持外部 template 路径）
- 不要提交密钥与 Firebase 配置文件
