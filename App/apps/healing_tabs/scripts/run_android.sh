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
# shellcheck disable=SC1091
source "$ROOT/scripts/android_env.sh"
cd "$ROOT"

# Ensure yc_product_plugin Android patches are applied before Gradle runs.
if [[ -x "$ROOT/tool/patch_yc_product_plugin_agp9.sh" ]]; then
  "$ROOT/tool/patch_yc_product_plugin_agp9.sh" || true
fi

if [[ "${1:-}" == "--devices" || "${1:-}" == "-l" ]]; then
  echo "已连接的 Android 设备："
  adb devices -l || true
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
    target = (device.get("targetPlatform") or device.get("platform") or "")
    if not str(target).startswith("android"):
        continue
    if not device.get("isSupported", True):
        continue
    print(device["id"])
    sys.exit(0)

sys.exit(1)
'
}

wait_for_android_device() {
  echo "→ 等待 Android 真机连接（USB 调试）…"
  echo "  请确认：手机已用数据线连接、已开启「开发者选项 → USB 调试」，并在弹窗点「允许」。"
  adb start-server >/dev/null 2>&1 || true
  if ! adb wait-for-device shell getprop ro.product.model >/dev/null 2>&1; then
    return 1
  fi
  # unauthorized devices still show up; wait until a device is "device"
  local tries=0
  while (( tries < 60 )); do
    if adb devices | awk 'NR>1 && $2=="device" {found=1} END{exit !found}'; then
      return 0
    fi
    if adb devices | awk 'NR>1 && $2=="unauthorized" {found=1} END{exit !found}'; then
      echo "  手机显示为 unauthorized：请在手机上点「允许 USB 调试」。"
    fi
    sleep 2
    tries=$((tries + 1))
  done
  return 1
}

if [[ -z "$DEVICE_ID" ]]; then
  echo "→ 正在查找已连接的 Android 设备…"
  if ! DEVICE_ID="$(pick_android_device)"; then
    if wait_for_android_device && DEVICE_ID="$(pick_android_device)"; then
      :
    else
      echo "未找到 Android 设备。请连接手机并开启 USB 调试。" >&2
      echo "查看设备: ./scripts/run_android.sh --devices" >&2
      echo "或指定 ID: ./scripts/run_android.sh <device_id>" >&2
      echo >&2
      adb devices -l || true
      flutter devices
      exit 1
    fi
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
