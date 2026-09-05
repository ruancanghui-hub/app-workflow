#!/usr/bin/env bash
# 快捷启动 healing_tabs（dev 变体，自动选设备）
# 用法: ./run.sh [ios|android|<device_id>|--devices]
exec "$(cd "$(dirname "$0")" && pwd)/scripts/run.sh" "$@"
