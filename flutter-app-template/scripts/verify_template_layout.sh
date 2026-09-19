#!/usr/bin/env bash
# Verify template/ layout conventions (see docs/flutter-create-template-conventions.md).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/template"
STRICT=0

for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    -h|--help)
      echo "Usage: $0 [--strict]"
      echo "  default: ensure template/ exists; list missing required files (exit 0)."
      echo "  --strict: exit 1 if any required file is missing."
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

REQUIRED=(
  "pubspec.yaml"
  "lib"
  "android"
  "ios"
  "analysis_options.yaml"
  "test"
)

if [[ ! -d "$TEMPLATE" ]]; then
  echo "FAIL: template/ directory missing at $TEMPLATE"
  exit 1
fi

echo "OK: template/ exists"
echo "Required layout entries (filled by later tickets):"

missing=0
for rel in "${REQUIRED[@]}"; do
  path="$TEMPLATE/$rel"
  if [[ -e "$path" ]]; then
    echo "  [x] $rel"
  else
    echo "  [ ] $rel  (not yet)"
    missing=1
  fi
done

if [[ "$STRICT" -eq 1 && "$missing" -eq 1 ]]; then
  echo "FAIL: --strict and required entries missing"
  exit 1
fi

echo "Done (strict=$STRICT)."
exit 0
