#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
FIXTURE="$ROOT/tests/fixtures/external-skills-repo"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install coding-conventions)
(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install "$FIXTURE" --skill external-audit --allow-external --yes)

jq -e '.schemaVersion == 2 and (.skills|length)==1 and .skills[0] == "coding-conventions" and (.externals|length)==1 and .externals[0].skills[0] == "external-audit" and .template == null and .source == "github:kyeongsoo-yoo/agent-foundry"' "$TMP/skills-lock.json" >/dev/null
[[ -f "$TMP/.agents/skills/coding-conventions/SKILL.md" ]]
[[ -f "$TMP/.agents/skills/external-audit/SKILL.md" ]]

