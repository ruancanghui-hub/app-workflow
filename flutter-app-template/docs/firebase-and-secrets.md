# Firebase & secrets

Do **not** commit real Firebase credentials.

## Enable Firebase adapters

1. Add local (gitignored) files such as:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - optional `lib/firebase_options.dart` from FlutterFire CLI
2. Run with:

```bash
flutter run --flavor dev \
  --dart-define=APP_VARIANT=dev \
  --dart-define=FIREBASE_CONFIGURED=true
```

Without `FIREBASE_CONFIGURED=true`, the app uses fake/no-op **运维底座** adapters and still starts.

## Other dart-defines

| Define | Default | Purpose |
|--------|---------|---------|
| `APP_VARIANT` | `dev` | `dev` / `prod` **构建变体** |
| `APP_INSTANCE_ID` | `app_template_local` | **应用实例身份** id |
| `APP_INSTANCE_NAME` | `App Template` | Display name |
| `OPS_CONSOLE_BASE_URL` | _(empty)_ | **应用运营台** base URL; empty = no-op |
| `FIREBASE_CONFIGURED` | `false` | Gate real Firebase init |
