#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/skills-lock.json" <<'JSON'
{
  "hub": "YOOGOMJA/agent-foundry",
  "installedAt": "2026-01-01T00:00:00Z",
  "skills": ["coding-conventions"]
}
JSON

bash "$ROOT/scripts/update-skills.sh" --repo-root "$ROOT" --target "$TMP"

[[ -f "$TMP/.agents/skills/coding-conventions/SKILL.md" ]]
REF="$(git -C "$ROOT" rev-parse HEAD)"
jq -e --arg ref "$REF" '.schemaVersion == 2 and .source == "github:kyeongsoo-yoo/agent-foundry" and .ref == $ref and (.skills|length)==1 and (.externals|length)==0 and .skills[0] == "coding-conventions"' "$TMP/skills-lock.json" >/dev/null
