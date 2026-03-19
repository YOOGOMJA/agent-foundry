#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/scripts/bootstrap-project.sh" \
  --repo-root "$ROOT" \
  --target "$TMP" \
  --template frontend \
  --skills vercel-react-best-practices,coding-conventions

[[ -f "$TMP/AGENTS.md" ]]
[[ -f "$TMP/skills-lock.json" ]]
[[ -f "$TMP/.agents/skills/coding-conventions/SKILL.md" ]]
[[ -f "$TMP/.agents/skills/vercel-react-best-practices/SKILL.md" ]]
jq -e '.schemaVersion == 2 and .source == "github:kyeongsoo-yoo/agent-foundry" and .template == "frontend" and (.skills|index("coding-conventions") != null) and (.skills|index("vercel-react-best-practices") != null) and (.externals|type=="array")' "$TMP/skills-lock.json" >/dev/null
