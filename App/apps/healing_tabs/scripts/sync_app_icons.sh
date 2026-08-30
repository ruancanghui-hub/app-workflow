#!/usr/bin/env bash
# Sync brand icons from assets/images/icons → iOS AppIcon + Android mipmap.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_SRC="$ROOT/assets/images/icons/ios/AppIcon.appiconset"
IOS_DST="$ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_SRC="$ROOT/assets/images/icons/android"

if [[ ! -d "$IOS_SRC" ]]; then
  echo "Missing iOS icon source: $IOS_SRC" >&2
  exit 1
fi

echo "→ iOS AppIcon.appiconset"
mkdir -p "$IOS_DST"
rm -f "$IOS_DST"/Icon-App-*.png "$IOS_DST"/icon-*.png
cp "$IOS_SRC"/Contents.json "$IOS_DST"/Contents.json
cp "$IOS_SRC"/icon-*.png "$IOS_DST"/

echo "→ Android mipmap"
for density in ldpi mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  src="$ANDROID_SRC/mipmap-$density/ic_launcher.png"
  dst_dir="$ROOT/android/app/src/main/res/mipmap-$density"
  if [[ -f "$src" ]]; then
    mkdir -p "$dst_dir"
    cp "$src" "$dst_dir/ic_launcher.png"
    echo "  mipmap-$density"
  fi
done

echo "✓ Icons synced from assets/images/icons"
