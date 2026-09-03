# 云遥 Firebase（项目 ID: smartliving-3338b）

云遥 App 已接入 Firebase 项目 `smartliving-3338b`（[控制台](https://console.firebase.google.com/project/smartliving-3338b/overview?hl=zh-cn)）。

> 控制台里的「项目名称」可在 Firebase 项目设置中改成「云遥」；**项目 ID** `smartliving-3338b` 创建后不可改，代码仍指向该 ID。

## 已启用

| 能力 | 包 | 说明 |
|---|---|---|
| Core | `firebase_core` | `DefaultFirebaseOptions` → `smartliving-3338b` |
| Analytics | `firebase_analytics` | 经 `FirebaseAnalyticsAdapter` |
| Crashlytics | `firebase_crashlytics` | 未捕获错误自动上报 |
| Remote Config | `firebase_remote_config` | 启动时 `fetchAndActivate` |

## 配置文件

- `lib/firebase_options.dart`（FlutterFire 生成）
- `ios/Runner/GoogleService-Info.plist`（Bundle `com.nightelf.yunyao`）
- `android/app/google-services.json`（包名 `com.nightelf.yunyao`）
- `dart_defines.*.json` → `FIREBASE_CONFIGURED: "true"`

## 运行

必须带 defines，否则仍走假实现：

```bash
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
# 或
./scripts/run_android.sh
```

## 控制台建议勾选

在 [Firebase Console](https://console.firebase.google.com/project/smartliving-3338b/overview?hl=zh-cn) 为该项目启用：

1. Analytics（Google Analytics）
2. Crashlytics
3. Remote Config（可加 `demo_flag` 等键）

重新生成配置：

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire configure --project=smartliving-3338b --platforms=ios,android \
  --ios-bundle-id=com.nightelf.yunyao --android-package-name=com.nightelf.yunyao --yes
```
