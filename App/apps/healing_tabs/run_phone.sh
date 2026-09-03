#!/usr/bin/env bash
# 快捷启动：在 Android 真机上运行 healing_tabs（dev 变体）
# 用法: ./run_phone.sh [设备ID]
exec "$(cd "$(dirname "$0")" && pwd)/scripts/run_android.sh" "$@"
