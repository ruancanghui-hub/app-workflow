#!/usr/bin/env bash
# macOS 双击启动器：安装并运行 healing_tabs 到已连接的 Android 真机（dev）
#
# 用法：
#   1. 手机用 USB 连接，开启「USB 调试」，弹窗点允许
#   2. 双击本文件（首次若被拦截：右键 → 打开）
#   3. 终端会自动编译并安装到手机
#
# 也可在终端执行：
#   open "./安装运行到安卓手机.command"
#   或指定设备：DEVICE_ID=4a2f2e04 open ...（见下方说明）
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# 双击启动时 PATH 往往不完整，补上常见 Flutter / Homebrew
export PATH="${HOME}/flutter/bin:${HOME}/development/flutter/bin:/opt/homebrew/bin:/usr/local/bin:${PATH}"

# shellcheck disable=SC1091
source "$ROOT/scripts/android_env.sh"

clear 2>/dev/null || true
echo "════════════════════════════════════════"
echo "  healing_tabs → Android 真机"
echo "  项目: $ROOT"
echo "════════════════════════════════════════"
echo

if ! command -v flutter >/dev/null 2>&1; then
  echo "未找到 flutter。请先安装 Flutter，或把 flutter 加入 PATH。" >&2
  echo
  read -r -p "按回车关闭窗口…" _
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "未找到 adb。请确认 Android SDK platform-tools 已安装，" >&2
  echo "或检查 scripts/android_env.sh 中的 ANDROID_HOME。" >&2
  echo
  read -r -p "按回车关闭窗口…" _
  exit 1
fi

echo "→ 已连接设备："
adb devices -l || true
echo

# 可选：在「显示简介」旁用环境变量传入设备，或拖入终端后附加参数
#   HEALING_TABS_DEVICE_ID=xxxx ./安装运行到安卓手机.command
EXTRA_ARGS=()
if [[ -n "${HEALING_TABS_DEVICE_ID:-}" ]]; then
  EXTRA_ARGS+=("$HEALING_TABS_DEVICE_ID")
elif [[ $# -gt 0 ]]; then
  EXTRA_ARGS+=("$@")
fi

set +e
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  "$ROOT/scripts/run_android.sh" "${EXTRA_ARGS[@]}"
else
  "$ROOT/scripts/run_android.sh"
fi
CODE=$?
set -e

echo
if [[ $CODE -eq 0 ]]; then
  echo "已结束（退出码 0）。"
else
  echo "失败（退出码 $CODE）。常见排查："
  echo "  · 手机未授权 USB 调试 → 重新插线并点「允许」"
  echo "  · 查看设备：./scripts/run_android.sh --devices"
  echo "  · 指定设备：HEALING_TABS_DEVICE_ID=<id> open \"./安装运行到安卓手机.command\""
fi
echo
read -r -p "按回车关闭窗口…" _
exit "$CODE"
