#!/usr/bin/env bash
# Patch yc_product_plugin for AGP 9+, flaky Aliyun mirrors, missing Android stubs, and sync-time NPE.
#
# Resolves plugin path in order:
#   1) $ROOT/third_party/yc_product_plugin/android  (preferred, durable)
#   2) Flutter pub-cache git checkout of yc_product_plugin
#
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

resolve_plugin_android() {
  local local_path="$ROOT/third_party/yc_product_plugin/android"
  if [[ -f "$local_path/build.gradle" ]]; then
    echo "$local_path"
    return 0
  fi

  local hit
  hit="$(find "${PUB_CACHE:-$HOME/.pub-cache}/git" -path '*/yc_product_plugin*/code/android/build.gradle' 2>/dev/null | head -1 || true)"
  if [[ -n "$hit" ]]; then
    dirname "$hit"
    return 0
  fi
  return 1
}

PLUGIN_ANDROID="$(resolve_plugin_android || true)"
if [[ -z "${PLUGIN_ANDROID:-}" ]]; then
  echo "missing yc_product_plugin android dir (third_party or pub-cache)" >&2
  exit 1
fi

TARGET="$PLUGIN_ANDROID/build.gradle"
SETTING_JAVA="$PLUGIN_ANDROID/src/main/java/com/example/yc_product_plugin/YcProductPluginSetting.java"
COLLECT_JAVA="$PLUGIN_ANDROID/src/main/java/com/example/yc_product_plugin/YcProductPluginCollectData.java"
echo "patching $PLUGIN_ANDROID"

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
t2 = "\n".join(ln for ln in t.splitlines() if "maven.aliyun.com" not in ln) + ("\n" if t.endswith("\n") else "")
t2 = t2.replace(
    "implementation 'com.lai.weavey:dialog:2.0.1'",
    "implementation(name: 'dialog-2.0.1', ext: 'aar')",
)
if t2 != t:
    p.write_text(t2)
    print("cleaned aliyun repos / dialog dep in", p)
else:
    print("build.gradle already cleaned")
PY

# 3) Vendor dialog aar into plugin libs if missing
DIALOG_AAR="$PLUGIN_ANDROID/libs/dialog-2.0.1.aar"
mkdir -p "$PLUGIN_ANDROID/libs"
if [[ ! -f "$DIALOG_AAR" ]]; then
  CACHED="$(find "$HOME/.gradle/caches/modules-2/files-2.1/com.lai.weavey/dialog/2.0.1" -name 'dialog-2.0.1.aar' 2>/dev/null | head -1 || true)"
  if [[ -n "$CACHED" ]]; then
    cp "$CACHED" "$DIALOG_AAR"
    echo "copied dialog aar from gradle cache"
  elif curl -fsSL -o "$DIALOG_AAR" "https://maven.aliyun.com/repository/public/com/lai/weavey/dialog/2.0.1/dialog-2.0.1.aar"; then
    echo "downloaded dialog aar"
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
if 'setDeviceSyncPhoneTime: hashMap is null' in t:
    print('setDeviceSyncPhoneTime already patched')
elif old not in t:
    print('WARN: setDeviceSyncPhoneTime pattern not found', file=sys.stderr)
else:
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

# 5) Missing Android stub: stopSyncCollectData (declared on MethodChannel, unimplemented)
if [[ -f "$COLLECT_JAVA" ]] && ! grep -q 'stopSyncCollectData' "$COLLECT_JAVA"; then
  python3 - "$COLLECT_JAVA" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
t = p.read_text()
stub = '''
    /**
     * 停止同步采集数据（上游插件声明了 MethodChannel，但 Android 端未实现）。
     * Android YCBTClient 无对应 API，返回 succeed 以保持通道可用。
     */
    public static void stopSyncCollectData(Object arguments, @NonNull MethodChannel.Result result) {
        HashMap map = new HashMap();
        map.put("code", YcProductPluginFlutterType.PluginState.succeed);
        map.put("data", "");
        result.success(map);
    }

'''
marker = "    /**\n     * 删除采集数据\n     */"
if marker not in t:
    print('WARN: deleteCollectData marker not found', file=sys.stderr)
else:
    p.write_text(t.replace(marker, stub + marker, 1))
    print('patched stopSyncCollectData stub')
PY
elif [[ -f "$COLLECT_JAVA" ]]; then
  echo "stopSyncCollectData already present"
fi

echo "done"
