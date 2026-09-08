#!/usr/bin/env bash
# macOS 双击启动器：安装并运行 healing_tabs 到 iPhone1999（dev）
#
# 用法：
#   1. iPhone 用 USB 连接（或已配对的无线调试），解锁并信任本机
#   2. 双击本文件（首次若被拦截：右键 → 打开）
#   3. 终端会自动编译并安装到 iPhone1999
#
# 也可在终端执行：
#   open "./安装运行到iPhone1999.command"
#   或指定其它设备：HEALING_TABS_DEVICE_ID=<id> ./安装运行到iPhone1999.command
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# 双击启动时 PATH 往往不完整，补上常见 Flutter / Homebrew
export PATH="${HOME}/flutter/bin:${HOME}/development/flutter/bin:/opt/homebrew/bin:/usr/local/bin:${PATH}"

# 本机 GitHub HTTPS 常失败，SSH 可用：仅本次会话把 https://github.com/ 改写为 SSH
# （不写 ~/.gitconfig；CocoaPods 拉 firebase-ios-sdk 等依赖时需要）
if [[ -z "${GIT_CONFIG_COUNT:-}" ]]; then
  export GIT_CONFIG_COUNT=1
  export GIT_CONFIG_KEY_0='url.git@github.com:.insteadOf'
  export GIT_CONFIG_VALUE_0='https://github.com/'
fi

clear 2>/dev/null || true
echo "════════════════════════════════════════"
echo "  healing_tabs → iPhone1999"
echo "  项目: $ROOT"
echo "════════════════════════════════════════"
echo

if ! command -v flutter >/dev/null 2>&1; then
  echo "未找到 flutter。请先安装 Flutter，或把 flutter 加入 PATH。" >&2
  echo
  read -r -p "按回车关闭窗口…" _
  exit 1
fi

DEFAULT_NAME="iPhone1999"
DEFAULT_ID="c6ec43f678e1bd213f7dede1184c4fde2a41aaab"

echo "→ 已连接设备："
flutter devices || true
echo

resolve_device_id() {
  local prefer_name="$1"
  local prefer_id="$2"
  flutter devices --machine 2>/dev/null | PREFER_NAME="$prefer_name" PREFER_ID="$prefer_id" python3 -c '
import json, os, sys
prefer_name = os.environ.get("PREFER_NAME", "").strip().lower()
prefer_id = os.environ.get("PREFER_ID", "").strip()
try:
    devices = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)

def ok(d):
    return bool(d.get("isSupported", True))

def is_ios(d):
    target = str(d.get("targetPlatform") or d.get("platform") or "")
    return target == "ios" or target.startswith("ios")

# 1) exact id
for d in devices:
    if ok(d) and d.get("id") == prefer_id:
        print(d["id"]); sys.exit(0)
# 2) name match (case-insensitive contains)
for d in devices:
    if not ok(d) or not is_ios(d):
        continue
    name = str(d.get("name") or "").lower()
    if prefer_name and prefer_name in name:
        print(d["id"]); sys.exit(0)
sys.exit(1)
'
}

DEVICE_ID="${HEALING_TABS_DEVICE_ID:-}"
if [[ -z "$DEVICE_ID" && $# -gt 0 ]]; then
  DEVICE_ID="$1"
fi

if [[ -z "$DEVICE_ID" ]]; then
  if ! DEVICE_ID="$(resolve_device_id "$DEFAULT_NAME" "$DEFAULT_ID")"; then
    echo "未找到 ${DEFAULT_NAME}。" >&2
    echo "请确认手机已解锁、已信任本机，然后重试。" >&2
    echo
    read -r -p "按回车关闭窗口…" _
    exit 1
  fi
fi

echo "→ 目标设备: $DEVICE_ID"
echo

set +e
"$ROOT/scripts/run.sh" "$DEVICE_ID"
CODE=$?
set -e

echo
if [[ $CODE -eq 0 ]]; then
  echo "已结束（退出码 0）。"
else
  echo "失败（退出码 $CODE）。常见排查："
  echo "  · 手机未解锁 / 未信任电脑"
  echo "  · 查看设备：./scripts/run.sh --devices"
  echo "  · 指定设备：HEALING_TABS_DEVICE_ID=<id> open \"./安装运行到iPhone1999.command\""
  echo "  · 首次 iOS 可能需要在 Xcode 里签好开发者证书"
fi
echo
read -r -p "按回车关闭窗口…" _
exit "$CODE"
