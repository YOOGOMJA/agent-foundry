#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/manifests"
cat > "$TMP/manifests/catalog.json" <<'JSON'
{
  "skills": [],
  "docs": [
    {
      "type": "goal",
      "source": "templates/handoff/goal.md",
      "destination": "docs/repo-suggest.md"
    },
    {
      "type": "broken",
      "source": "templates/handoff/goal.md"
    }
  ]
}
JSON

OUT="$(node "$ROOT/bin/agent-foundry.js" docs suggest --repo "$TMP")"

echo "$OUT" | grep -q "docs/repo-suggest.md"
echo "$OUT" | grep -q "invalid mapping"

