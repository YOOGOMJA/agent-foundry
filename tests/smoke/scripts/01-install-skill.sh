#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/scripts/install-skill.sh" \
  --repo-root "$ROOT" \
  --target "$TMP" \
  --skill vercel-react-best-practices

[[ -f "$TMP/.agents/skills/vercel-react-best-practices/SKILL.md" ]]
