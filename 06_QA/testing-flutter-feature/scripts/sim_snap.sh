#!/usr/bin/env bash
# Hot-restart the running `flutter run` (SIGUSR2) and screenshot the booted iOS simulator.
#
# Usage:
#   sim_snap.sh <name> [output_dir] [--no-restart] [--wait <seconds>]
#
# Default output: output/qa/feature/<YYYYMMDD>/<name>.png (relative to the current directory).
set -euo pipefail

NAME=""
OUT_DIR=""
RESTART=1
WAIT=6

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-restart) RESTART=0; shift ;;
    --wait) WAIT="$2"; shift 2 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *)
      if [[ -z "$NAME" ]]; then NAME="$1"
      elif [[ -z "$OUT_DIR" ]]; then OUT_DIR="$1"
      else echo "ERROR: unexpected argument $1" >&2; exit 2
      fi
      shift ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Usage: $0 <name> [output_dir] [--no-restart] [--wait <seconds>]" >&2
  exit 2
fi
OUT_DIR="${OUT_DIR:-output/qa/feature/$(date +%Y%m%d)}"

if ! xcrun simctl list devices booted | grep -q "(Booted)"; then
  echo "ERROR: no booted iOS simulator; run: open -a Simulator" >&2
  exit 1
fi

if [[ "$RESTART" == 1 ]]; then
  PID="$(pgrep -f "flutter_tools.snapshot run" | head -1 || true)"
  if [[ -n "$PID" ]]; then
    kill -USR2 "$PID"
    echo "hot restart sent to flutter run (pid $PID); waiting ${WAIT}s"
    sleep "$WAIT"
  else
    echo "WARN: no running 'flutter run' found; capturing the current screen" >&2
  fi
fi

mkdir -p "$OUT_DIR"
FILE="$OUT_DIR/$NAME.png"
if ! LOG="$(xcrun simctl io booted screenshot "$FILE" 2>&1)"; then
  echo "$LOG" >&2
  exit 1
fi
echo "$FILE"
