#!/usr/bin/env bash
# Sync flutter-app-template from yunyao main into this monorepo.
# Usage:
#   bash 00_Orchestrator/app-workflow/scripts/sync_flutter_app_template.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
DEST="$REPO_ROOT/flutter-app-template"
REMOTE_URL="${FLUTTER_TEMPLATE_GIT_URL:-https://github.com/ruancanghui-hub/yunyao.git}"
REMOTE_REF="${FLUTTER_TEMPLATE_GIT_REF:-main}"
SPARSE_PATH="flutter-app-template"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/yunyao-tpl-XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

echo "Cloning $REMOTE_URL ($REMOTE_REF) sparse:$SPARSE_PATH …"
git clone --depth 1 --filter=blob:none --sparse --branch "$REMOTE_REF" "$REMOTE_URL" "$TMP"
git -C "$TMP" sparse-checkout set "$SPARSE_PATH"

if [[ ! -d "$TMP/$SPARSE_PATH/template" ]]; then
  echo "ERROR: missing $SPARSE_PATH/template in remote" >&2
  exit 1
fi

# Replace destination (symlink or old tree)
if [[ -L "$DEST" || -d "$DEST" ]]; then
  BACKUP="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
  mv "$DEST" "$BACKUP"
  echo "backed up previous template -> $BACKUP"
fi

cp -R "$TMP/$SPARSE_PATH" "$DEST"
COMMIT="$(git -C "$TMP" rev-parse HEAD)"
{
  echo "source=${REMOTE_URL%/}/tree/${REMOTE_REF}/${SPARSE_PATH}"
  echo "synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$DEST/.template-source"
echo "$COMMIT" > "$DEST/.template-source-commit"

"$DEST/scripts/verify_template_layout.sh" --strict
echo "OK: flutter-app-template @ $COMMIT"
echo "Path: $DEST"
