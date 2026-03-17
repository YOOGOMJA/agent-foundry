#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

[[ -f "$ROOT/manifests/skills.json" ]] || exit 1
# skills.json은 스킬명 -> {path, description} 맵 형식
jq -e 'type == "object" and (keys | length > 0) and (to_entries[0].value | has("path") and has("description"))' "$ROOT/manifests/skills.json" >/dev/null
for t in base frontend fullstack; do
  [[ -f "$ROOT/templates/agents/$t.md" ]] || exit 1
done
