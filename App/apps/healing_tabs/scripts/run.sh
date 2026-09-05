#!/usr/bin/env bash
# 启动 healing_tabs（默认 dev 变体）
#
# 必须在 healing_tabs 项目根目录执行（或从根目录 ./run.sh 调用）。
#
# 用法:
#   ./scripts/run.sh                 # 自动选择设备（真机 > 模拟器）
#   ./scripts/run.sh ios             # 优先 iOS
#   ./scripts/run.sh android         # 优先 Android
#   ./scripts/run.sh <device_id>     # 指定设备 ID
#   ./scripts/run.sh --devices       # 列出设备
#   FLAVOR=prod DEFINES_FILE=dart_defines.prod.json ./scripts/run.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/android_env.sh"
cd "$ROOT"

FLAVOR="${FLAVOR:-dev}"
DEFINES_FILE="${DEFINES_FILE:-dart_defines.${FLAVOR}.json}"
PREFER="${HEALING_TABS_PLATFORM:-}"
DEVICE_ID="${HEALING_TABS_DEVICE_ID:-}"

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--devices" || "${1:-}" == "-l" ]]; then
  flutter devices
  exit 0
fi

case "${1:-}" in
  ios|android)
    PREFER="$1"
    shift
    ;;
esac

if [[ -n "${1:-}" ]]; then
  DEVICE_ID="$1"
fi

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "缺少 $DEFINES_FILE，请在 healing_tabs 项目根目录执行。" >&2
  exit 1
fi

pick_device() {
  local prefer="$1"
  flutter devices --machine 2>/dev/null | PREFER="$prefer" python3 -c '
import json
import os
import sys

prefer = os.environ.get("PREFER", "").strip().lower()

try:
    devices = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)

def ok(d):
    return bool(d.get("isSupported", True))

def is_ios(d):
    target = str(d.get("targetPlatform") or d.get("platform") or "")
    return target == "ios" or target.startswith("ios")

def is_android(d):
    target = str(d.get("targetPlatform") or d.get("platform") or "")
    return target.startswith("android")

def is_simulator(d):
    # Flutter machine JSON: emulator=true for simulators / emulators
    return bool(d.get("emulator", False))

ios_physical = []
ios_sim = []
android_physical = []
android_emu = []

for d in devices:
    if not ok(d):
        continue
    if is_ios(d):
        (ios_sim if is_simulator(d) else ios_physical).append(d)
    elif is_android(d):
        (android_emu if is_simulator(d) else android_physical).append(d)

ordered = []
if prefer == "ios":
    ordered = ios_physical + ios_sim + android_physical + android_emu
elif prefer == "android":
    ordered = android_physical + android_emu + ios_physical + ios_sim
else:
    # 真机优先，其次 iOS 模拟器，再 Android 模拟器
    ordered = ios_physical + android_physical + ios_sim + android_emu

if not ordered:
    sys.exit(1)

print(ordered[0]["id"])
'
}

if [[ -z "$DEVICE_ID" ]]; then
  if [[ -n "$PREFER" ]]; then
    echo "→ 正在查找可用设备（优先 ${PREFER}）…"
  else
    echo "→ 正在查找可用设备…"
  fi
  if ! DEVICE_ID="$(pick_device "$PREFER")"; then
    echo "未找到可用设备。" >&2
    echo "查看设备: ./scripts/run.sh --devices" >&2
    echo "或指定 ID: ./scripts/run.sh <device_id>" >&2
    echo >&2
    flutter devices
    exit 1
  fi
fi

echo "→ 项目: $ROOT"
echo "→ 设备: $DEVICE_ID"
echo "→ 变体: $FLAVOR"
echo "→ 命令: flutter run --flavor $FLAVOR --dart-define-from-file=$DEFINES_FILE -d $DEVICE_ID"
echo

exec flutter run \
  --flavor "$FLAVOR" \
  --dart-define-from-file="$DEFINES_FILE" \
  -d "$DEVICE_ID"
