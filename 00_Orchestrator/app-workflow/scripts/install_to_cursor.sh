#!/usr/bin/env bash
# Compat wrapper: install into Cursor skills (same as install_skills.sh cursor).
set -euo pipefail
exec "$(cd "$(dirname "$0")" && pwd)/install_skills.sh" cursor
