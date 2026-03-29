#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
FIXTURE="$ROOT/tests/fixtures/external-skills-repo"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if (cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install "$FIXTURE" --skill external-audit 2>/dev/null); then
  echo "expected install without --allow-external to fail"
  exit 1
fi

(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install "$FIXTURE" --skill external-audit --allow-external --yes)

[[ -f "$TMP/.agents/skills/external-audit/SKILL.md" ]]
REF="$(git -C "$ROOT" rev-parse HEAD)"
jq -e --arg ref "$REF" '.schemaVersion == 2 and .ref == $ref and (.skills|length)==0 and (.externals|length)==1 and .externals[0].source == "'"$FIXTURE"'" and .externals[0].ref == "local"' "$TMP/skills-lock.json" >/dev/null
