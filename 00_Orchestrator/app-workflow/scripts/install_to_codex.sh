#!/usr/bin/env bash
# Install app-workflow skills into Codex (~/.codex/skills).
set -euo pipefail
exec "$(cd "$(dirname "$0")" && pwd)/install_skills.sh" codex
