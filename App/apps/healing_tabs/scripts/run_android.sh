#!/usr/bin/env bash
# 构建并启动 healing_tabs 到 Android 真机（dev 变体）
#
# 必须在 healing_tabs 项目根目录执行（或从 run_phone.sh 调用）。
# 不要在 monorepo 根目录直接 flutter run，否则会报 No pubspec.yaml。
#
# 用法:
#   ./scripts/run_android.sh              # 自动选择第一台 Android 设备
#   ./scripts/run_android.sh 4a2f2e04   # 指定设备 ID（flutter devices 查看）
#   ./run_phone.sh                        # 根目录快捷方式
#   HEALING_TABS_DEVICE_ID=xxx ./scripts/run_android.sh
#   ./scripts/run_android.sh --devices    # 仅列出 Android 设备
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ "${1:-}" == "--devices" || "${1:-}" == "-l" ]]; then
  echo "已连接的 Android 设备："
  flutter devices | grep -E 'android|mobile' || flutter devices
  exit 0
fi

FLAVOR="${FLAVOR:-dev}"
DEFINES_FILE="${DEFINES_FILE:-dart_defines.dev.json}"
DEVICE_ID="${1:-${HEALING_TABS_DEVICE_ID:-}}"

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "缺少 $DEFINES_FILE，请在 healing_tabs 项目根目录执行。" >&2
  exit 1
fi

pick_android_device() {
  flutter devices --machine 2>/dev/null | python3 -c '
import json
import sys

try:
    devices = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)

for device in devices:
    if device.get("platform") != "android":
        continue
    if not device.get("isSupported", True):
        continue
    print(device["id"])
    sys.exit(0)

sys.exit(1)
'
}

if [[ -z "$DEVICE_ID" ]]; then
  echo "→ 正在查找已连接的 Android 设备…"
  if ! DEVICE_ID="$(pick_android_device)"; then
    echo "未找到 Android 设备。请连接手机并开启 USB 调试。" >&2
    echo "查看设备: ./scripts/run_android.sh --devices" >&2
    echo "或指定 ID: ./scripts/run_android.sh <device_id>" >&2
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
