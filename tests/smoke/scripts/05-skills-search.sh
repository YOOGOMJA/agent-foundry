#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

CURATED_OUT="$(node "$ROOT/bin/agent-foundry.js" skills search coding --source curated)"
printf '%s\n' "$CURATED_OUT" | grep -q "coding-conventions"
printf '%s\n' "$CURATED_OUT" | grep -q "curated"

ALL_OUT="$(node "$ROOT/bin/agent-foundry.js" skills search --source all)"
printf '%s\n' "$ALL_OUT" | grep -q "shared-git-workflow"
printf '%s\n' "$ALL_OUT" | grep -q "external"

node "$ROOT/bin/agent-foundry.js" skills install coding-conventions --output "$TMP/install-out" >/dev/null
[[ -f "$TMP/install-out/.agents/skills/coding-conventions/SKILL.md" ]]

node "$ROOT/bin/agent-foundry.js" skills install vercel-react-best-practices --output "$TMP/catalog-install" >/dev/null
[[ -f "$TMP/catalog-install/.agents/skills/vercel-react-best-practices/SKILL.md" ]]
