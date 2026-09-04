#!/usr/bin/env bash
# Patch yc_product_plugin for AGP 9+, flaky Aliyun mirrors, and sync-time NPE.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_ANDROID="$ROOT/third_party/yc_product_plugin/android"
TARGET="$PLUGIN_ANDROID/build.gradle"
SETTING_JAVA="$PLUGIN_ANDROID/src/main/java/com/example/yc_product_plugin/YcProductPluginSetting.java"
if [[ ! -f "$TARGET" ]]; then
  echo "missing $TARGET (ensure pubspec_overrides + flutter pub get)" >&2
  exit 1
fi

# 1) AGP 9 rejects proguard-android.txt
if grep -q "proguard-android.txt" "$TARGET"; then
  sed -i.bak "s/getDefaultProguardFile('proguard-android.txt')/getDefaultProguardFile('proguard-android-optimize.txt')/" "$TARGET"
  rm -f "${TARGET}.bak"
  echo "patched proguard default"
fi

# 2) Prefer google/mavenCentral; drop Aliyun mirrors that 502 and poison resolution
python3 - "$TARGET" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
t = p.read_text()
t = re.sub(r"\s*maven \{ url 'https://maven\.aliyun\.com/repository/[^']+'/?\}\s*\n", "\n", t)
t = t.replace(
    "implementation 'com.lai.weavey:dialog:2.0.1'",
    "implementation(name: 'dialog-2.0.1', ext: 'aar')",
)
p.write_text(t)
print("cleaned aliyun repos / dialog dep in", p)
PY

# 3) Vendor dialog aar into plugin libs if missing
DIALOG_AAR="$PLUGIN_ANDROID/libs/dialog-2.0.1.aar"
if [[ ! -f "$DIALOG_AAR" ]]; then
  CACHED="$(find "$HOME/.gradle/caches/modules-2/files-2.1/com.lai.weavey/dialog/2.0.1" -name 'dialog-2.0.1.aar' 2>/dev/null | head -1 || true)"
  if [[ -n "$CACHED" ]]; then
    cp "$CACHED" "$DIALOG_AAR"
    echo "copied dialog aar from gradle cache"
  else
    echo "WARN: dialog-2.0.1.aar missing; build may fail until aar is placed in $DIALOG_AAR" >&2
  fi
fi

# 4) Guard setDeviceSyncPhoneTime against null hashMap (NPE breaks BLE queue)
if [[ -f "$SETTING_JAVA" ]] && grep -q 'int state = (int) hashMap.get("code");' "$SETTING_JAVA"; then
  python3 - "$SETTING_JAVA" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
t = p.read_text()
old = '''            public void onDataResponse(int i, float v, HashMap hashMap) {
                int state = (int) hashMap.get("code");
                HashMap map = new HashMap();
                map.put("code", state);
                map.put("data", "");
                result.success(map);
            }'''
new = '''            public void onDataResponse(int i, float v, HashMap hashMap) {
                HashMap map = new HashMap();
                if (hashMap == null) {
                    Log.w("MARK-", "setDeviceSyncPhoneTime: hashMap is null, code=" + i);
                    map.put("code", 1);
                    map.put("data", "");
                    result.success(map);
                    return;
                }
                Object codeObj = hashMap.get("code");
                int state = codeObj instanceof Number ? ((Number) codeObj).intValue() : i;
                map.put("code", state);
                map.put("data", "");
                result.success(map);
            }'''
# Only patch the first occurrence inside setDeviceSyncPhoneTime if still unpatched
if 'setDeviceSyncPhoneTime: hashMap is null' in t:
    print('setDeviceSyncPhoneTime already patched')
elif old not in t:
    print('WARN: setDeviceSyncPhoneTime pattern not found', file=sys.stderr)
else:
    # Replace only the settingTime callback (first hashMap.get("code") block after settingTime)
    idx = t.find('YCBTClient.settingTime')
    if idx < 0:
        print('WARN: settingTime not found', file=sys.stderr)
    else:
        head, tail = t[:idx], t[idx:]
        if old not in tail:
            print('WARN: callback pattern not after settingTime', file=sys.stderr)
        else:
            p.write_text(head + tail.replace(old, new, 1))
            print('patched setDeviceSyncPhoneTime null hashMap guard')
PY
fi

echo "done"
