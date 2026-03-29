#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install coding-conventions)

[[ -f "$TMP/.agents/skills/coding-conventions/SKILL.md" ]]
REF="$(git -C "$ROOT" rev-parse HEAD)"
jq -e --arg ref "$REF" '.schemaVersion == 2 and .source == "github:kyeongsoo-yoo/agent-foundry" and .ref == $ref and (.skills|length)==1 and (.externals|length)==0 and .template == null' "$TMP/skills-lock.json" >/dev/null
