# iOS build variants

Flutter on iOS expects **scheme names** that match Android flavor names (`dev`, `prod`),
and build configurations named `Debug-dev`, `Release-prod`, etc.

## Recommended commands

Always pass matching dart-define so **AppEnvironment** matches the flavor:

```bash
flutter run --flavor dev --dart-define=APP_VARIANT=dev
flutter run --flavor prod --dart-define=APP_VARIANT=prod
# or:
flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json
```

## Setup (once)

`create_from_template.sh` runs `scripts/setup_ios_flavor_build_configs.rb` to add
`Debug-dev` / `Release-prod` / … configurations. Re-run manually if needed:

```bash
# from App 模板 repo root; pass the instance ios/ path
ruby scripts/setup_ios_flavor_build_configs.rb /path/to/instance/ios
```

Fill local signing team:

```bash
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
# edit DEVELOPMENT_TEAM=
```

`AppEnvironment` reads `APP_VARIANT` (`dev` default, `prod` when set). Gradle flavors on Android
already provide distinct applicationIds (`*.dev` suffix for dev).
