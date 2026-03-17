#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/skills-lock.json" <<'JSON'
{
  "hub": "YOOGOMJA/agent-foundry",
  "version": "v0.1.0",
  "skills": ["coding-conventions"]
}
JSON

bash "$ROOT/scripts/update-skills.sh" --repo-root "$ROOT" --target "$TMP"
[[ -f "$TMP/.agents/skills/coding-conventions/SKILL.md" ]]
