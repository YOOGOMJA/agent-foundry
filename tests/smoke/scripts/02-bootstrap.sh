#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/scripts/bootstrap-project.sh" \
  --repo-root "$ROOT" \
  --target "$TMP" \
  --template frontend \
  --skills coding-conventions

[[ -f "$TMP/AGENTS.md" ]]
[[ -f "$TMP/skills-lock.json" ]]
[[ -f "$TMP/.agents/skills/coding-conventions/SKILL.md" ]]
