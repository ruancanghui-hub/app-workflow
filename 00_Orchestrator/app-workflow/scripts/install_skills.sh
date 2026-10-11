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
  install_skill "$dest_root" commercial-analysis-to-app-coverage "01_PRD/commercial-analysis-to-app-coverage"
  install_skill "$dest_root" creating-app-product-docs "01_PRD/creating-app-product-docs"
  install_skill "$dest_root" generate-app-brand-ip "02_IP/APP品牌IP生成"
  install_skill "$dest_root" regenerating-ui-redbox-assets "02_IP/regenerating-ui-redbox-assets"
  install_skill "$dest_root" converting-sliced-ui-to-html-figma "02_IP/converting-sliced-ui-to-html-figma"
  install_skill "$dest_root" composing-asset-ui-prototype "03_UI_UX/composing-asset-ui-prototype"
  install_skill "$dest_root" designing-prd-tab-ui "03_UI_UX/designing-prd-tab-ui"
  install_skill "$dest_root" designing-advanced-app-interactions "03_UI_UX/designing-advanced-app-interactions"
  install_skill "$dest_root" creating-app-prototypes "03_UI_UX/creating-app-prototypes"
  install_skill "$dest_root" create-flutter-app "04_Dev/create-flutter-app"
  install_skill "$dest_root" brand-ip-tabs-to-flutter "04_Dev/brand-ip-tabs-to-flutter"
  install_skill "$dest_root" implement-flutter-features "05_Feature/implement-flutter-features"
  install_skill "$dest_root" feature-quest-steward "05_Feature/feature-quest-steward"
  install_skill "$dest_root" regenerating-ui-assets-to-flutter-page "05_Feature/regenerating-ui-assets-to-flutter-page"
  install_skill "$dest_root" original-image-design-json-to-flutter-page "05_Feature/original-image-design-json-to-flutter-page"
  install_skill "$dest_root" annotated-ui-to-flutter-page "05_Feature/annotated-ui-to-flutter-page"
  install_skill "$dest_root" automating-flutter-app-tests "06_QA/automating-flutter-app-tests"
  install_skill "$dest_root" testing-flutter-feature "06_QA/testing-flutter-feature"
  install_skill "$dest_root" polish-app-quality "06_QA/polish-app-quality"
  install_skill "$dest_root" release-to-app-store "07_AppStore/release-to-app-store"
  install_skill "$dest_root" evolve-workflow "08_Learn/evolve-workflow"

  ln -sfn "$REPO_ROOT" "$dest_root/app-workflow-root"

  echo ""
  echo "[$label] APP_WORKFLOW_ROOT=$REPO_ROOT"
  echo "[$label] Installed 22 skills under $dest_root"
}

# Write the global feature-autotest rule into Codex AGENTS.md between markers (replaced, never duplicated).
install_codex_rule() {
  local agents_file="${CODEX_HOME:-$HOME/.codex}/AGENTS.md"
  local rule_file="$REPO_ROOT/00_Orchestrator/app-workflow/assets/global-rules/feature-autotest.md"
  local begin="<!-- app-workflow:feature-autotest:begin -->"
  local end="<!-- app-workflow:feature-autotest:end -->"

  if [[ ! -f "$rule_file" ]]; then
    echo "ERROR: missing $rule_file" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$agents_file")"
  touch "$agents_file"

  local kept
  kept="$(awk -v b="$begin" -v e="$end" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    skip { next }
    $0 == "" { blank++; next }
    { for (i = 0; i < blank; i++) print ""; blank = 0; print }
  ' "$agents_file")"

  {
    if [[ -n "$kept" ]]; then
      printf '%s\n\n' "$kept"
    fi
    echo "$begin"
    cat "$rule_file"
    echo "$end"
  } > "$agents_file"

  echo "[Codex] feature-autotest rule written to $agents_file"
}

case "$TARGET" in
  cursor)
    install_into "${HOME}/.cursor/skills" "Cursor"
    echo "Use /app-workflow (or \$app-workflow) in Cursor chat."
    ;;
  codex)
    install_into "${CODEX_HOME:-$HOME/.codex}/skills" "Codex"
    install_codex_rule
    echo "Use \$app-workflow in Codex on the next turn."
    ;;
  all)
    install_into "${HOME}/.cursor/skills" "Cursor"
    install_into "${CODEX_HOME:-$HOME/.codex}/skills" "Codex"
    install_codex_rule
    echo "Use /app-workflow in Cursor; \$app-workflow in Codex."
    ;;
  *)
    echo "Usage: $0 [cursor|codex|all]" >&2
    exit 2
    ;;
esac
