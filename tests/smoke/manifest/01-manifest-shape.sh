#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

[[ -f "$ROOT/manifests/skills.json" ]] || exit 1
jq -e '.version and .skills and (.skills | type == "array")' "$ROOT/manifests/skills.json" >/dev/null
for t in base frontend fullstack; do
  [[ -f "$ROOT/templates/agents/$t.md" ]] || exit 1
done
