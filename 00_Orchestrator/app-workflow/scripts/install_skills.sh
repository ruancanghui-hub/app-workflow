#!/usr/bin/env bash
# Install app-workflow skills into Cursor and/or Codex (symlink, idempotent).
#
# Usage:
#   ./install_to_cursor.sh              # Cursor only (compat)
#   ./install_skills.sh cursor
#   ./install_skills.sh codex
#   ./install_skills.sh all
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
TARGET="${1:-cursor}"

install_skill() {
  local dest_root="$1"
  local name="$2"
  local rel_path="$3"
  local source="$REPO_ROOT/$rel_path"
  local target="$dest_root/$name"

  if [[ ! -f "$source/SKILL.md" ]]; then
    echo "ERROR: missing $source/SKILL.md" >&2
    exit 1
  fi

  # Real directory (not symlink) → backup once, then replace with symlink
  if [[ -d "$target" && ! -L "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    echo "backed up existing $name -> $backup"
  fi

  ln -sfn "$source" "$target"
  echo "linked [$dest_root] $name -> $source"
}

install_into() {
  local dest_root="$1"
  local label="$2"

  mkdir -p "$dest_root"

  install_skill "$dest_root" app-workflow "00_Orchestrator/app-workflow"
  install_skill "$dest_root" creating-app-product-docs "01_PRD/creating-app-product-docs"
  install_skill "$dest_root" generate-app-brand-ip "02_IP/APP品牌IP生成"
  install_skill "$dest_root" creating-app-prototypes "03_UI_UX/creating-app-prototypes"
  install_skill "$dest_root" create-flutter-app "04_Dev/create-flutter-app"
  install_skill "$dest_root" implement-flutter-features "05_Feature/implement-flutter-features"
  install_skill "$dest_root" polish-app-quality "06_QA/polish-app-quality"
  install_skill "$dest_root" release-to-app-store "07_AppStore/release-to-app-store"
  install_skill "$dest_root" evolve-workflow "08_Learn/evolve-workflow"

  ln -sfn "$REPO_ROOT" "$dest_root/app-workflow-root"

  echo ""
  echo "[$label] APP_WORKFLOW_ROOT=$REPO_ROOT"
  echo "[$label] Installed 9 skills under $dest_root"
}

case "$TARGET" in
  cursor)
    install_into "${HOME}/.cursor/skills" "Cursor"
    echo "Use /app-workflow (or \$app-workflow) in Cursor chat."
    ;;
  codex)
    install_into "${CODEX_HOME:-$HOME/.codex}/skills" "Codex"
    echo "Use \$app-workflow in Codex on the next turn."
    ;;
  all)
    install_into "${HOME}/.cursor/skills" "Cursor"
    install_into "${CODEX_HOME:-$HOME/.codex}/skills" "Codex"
    echo "Use /app-workflow in Cursor; \$app-workflow in Codex."
    ;;
  *)
    echo "Usage: $0 [cursor|codex|all]" >&2
    exit 2
    ;;
esac
