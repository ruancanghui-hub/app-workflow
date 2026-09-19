#!/bin/bash
# macOS 双击启动：在 iOS / Android 真机上运行 App 模板（或模板实例）。
# 用法：双击本文件，或在终端执行 ./run-device.command
set -euo pipefail

pause() {
  echo ""
  # shellcheck disable=SC2162
  read -p "按回车键关闭窗口…" _ </dev/tty
}

trap 'code=$?; if [ "$code" -ne 0 ]; then echo ""; echo "失败 (exit $code)"; pause; fi' EXIT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 模板仓根 → 跑 template/；拷到实例根 → 跑当前目录
if [ -f "$SCRIPT_DIR/template/pubspec.yaml" ]; then
  APP_DIR="$SCRIPT_DIR/template"
elif [ -f "$SCRIPT_DIR/pubspec.yaml" ]; then
  APP_DIR="$SCRIPT_DIR"
else
  echo "找不到 Flutter 工程（需要 template/pubspec.yaml 或同级 pubspec.yaml）" >&2
  exit 1
fi

cd "$APP_DIR"
echo "工程目录: $APP_DIR"
echo ""

if ! command -v flutter >/dev/null 2>&1; then
  echo "未找到 flutter，请先安装并加入 PATH。" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "未找到 python3（用于解析 flutter devices）。" >&2
  exit 1
fi

# 仅真机：emulator == false，且平台为 ios / android*
# 输出: kind<TAB>id<TAB>name<TAB>sdk
list_physical_devices() {
  local platform_filter="${1:-all}" # all | ios | android
  flutter devices --machine 2>/dev/null | python3 -c '
import json, sys
filt = sys.argv[1]
raw = sys.stdin.read().strip()
if not raw:
    sys.exit(0)
devices = json.loads(raw)
for d in devices:
    if d.get("emulator", True):
        continue
    if not d.get("isSupported", True):
        continue
    platform = (d.get("targetPlatform") or "").lower()
    if platform.startswith("ios"):
        kind = "ios"
    elif platform.startswith("android"):
        kind = "android"
    else:
        continue
    if filt != "all" and kind != filt:
        continue
    name = d.get("name") or d.get("id")
    did = d.get("id") or ""
    sdk = d.get("sdk") or ""
    print("%s\t%s\t%s\t%s" % (kind, did, name, sdk))
' "$platform_filter"
}

choose_flavor() {
  echo "选择构建变体:" >&2
  echo "  1) dev  (默认)" >&2
  echo "  2) prod" >&2
  # shellcheck disable=SC2162
  read -p "请输入 [1]: " choice </dev/tty
  case "${choice:-1}" in
    2|prod|PROD) echo "prod" ;;
    *) echo "dev" ;;
  esac
}

choose_platform_filter() {
  echo "选择真机平台:" >&2
  echo "  1) 全部真机 (默认)" >&2
  echo "  2) 仅 iOS" >&2
  echo "  3) 仅 Android" >&2
  # shellcheck disable=SC2162
  read -p "请输入 [1]: " choice </dev/tty
  case "${choice:-1}" in
    2|ios|iOS|IOS) echo "ios" ;;
    3|android|Android|ANDROID) echo "android" ;;
    *) echo "all" ;;
  esac
}

echo "========================================"
echo "  Flutter 真机启动器 (iOS / Android)"
echo "========================================"
echo ""

PLATFORM_FILTER="$(choose_platform_filter)"
echo ""
echo "正在检测已连接真机…"

DEVICE_TMP="$(mktemp -t run-device.XXXXXX)"
trap 'rm -f "$DEVICE_TMP"; code=$?; if [ "$code" -ne 0 ]; then echo ""; echo "失败 (exit $code)"; pause; fi' EXIT

list_physical_devices "$PLATFORM_FILTER" >"$DEVICE_TMP" || true

DEVICE_COUNT="$(wc -l <"$DEVICE_TMP" | tr -d ' ')"

if [ "$DEVICE_COUNT" -eq 0 ]; then
  echo "未检测到可用真机。"
  echo "请确认："
  echo "  - iOS：数据线连接、已信任此电脑、开发者模式已开"
  echo "  - Android：USB 调试已开、已授权这台电脑"
  echo ""
  echo "当前 flutter devices："
  flutter devices || true
  exit 1
fi

echo ""
echo "可用真机："
i=1
while IFS= read -r line; do
  kind="$(printf '%s' "$line" | cut -f1)"
  did="$(printf '%s' "$line" | cut -f2)"
  name="$(printf '%s' "$line" | cut -f3)"
  sdk="$(printf '%s' "$line" | cut -f4)"
  label="$sdk"
  [ -n "$label" ] || label="$did"
  printf "  %d) [%s] %s  (%s)\n" "$i" "$kind" "$name" "$label"
  i=$((i + 1))
done <"$DEVICE_TMP"
echo ""

if [ "$DEVICE_COUNT" -eq 1 ]; then
  SELECTED="$(sed -n '1p' "$DEVICE_TMP")"
  echo "自动选择唯一真机。"
else
  # shellcheck disable=SC2162
  read -p "请选择设备编号 [1]: " idx </dev/tty
  idx="${idx:-1}"
  case "$idx" in
    ''|*[!0-9]*)
      echo "无效编号: $idx" >&2
      exit 1
      ;;
  esac
  if [ "$idx" -lt 1 ] || [ "$idx" -gt "$DEVICE_COUNT" ]; then
    echo "无效编号: $idx" >&2
    exit 1
  fi
  SELECTED="$(sed -n "${idx}p" "$DEVICE_TMP")"
fi

KIND="$(printf '%s' "$SELECTED" | cut -f1)"
DEVICE_ID="$(printf '%s' "$SELECTED" | cut -f2)"
DEVICE_NAME="$(printf '%s' "$SELECTED" | cut -f3)"

echo ""
echo "设备: [$KIND] $DEVICE_NAME ($DEVICE_ID)"
echo ""

FLAVOR="$(choose_flavor)"
DEFINES_FILE="dart_defines.${FLAVOR}.json"

if [ ! -f "$DEFINES_FILE" ]; then
  echo "缺少 $DEFINES_FILE。若是模板实例，请先 apply instance.config.yaml。" >&2
  exit 1
fi

echo ""
echo "执行: flutter run --flavor $FLAVOR --dart-define-from-file=$DEFINES_FILE -d $DEVICE_ID"
echo ""

flutter pub get
flutter run --flavor "$FLAVOR" --dart-define-from-file="$DEFINES_FILE" -d "$DEVICE_ID"

rm -f "$DEVICE_TMP"
trap - EXIT
pause
