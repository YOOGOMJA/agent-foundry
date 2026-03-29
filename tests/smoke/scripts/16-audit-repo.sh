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
      "destination": "docs/repo-audit.md"
    },
    {
      "type": "broken",
      "source": "templates/handoff/goal.md"
    }
  ]
}
JSON

OUT="$(node "$ROOT/bin/agent-foundry.js" audit --format json --repo "$TMP")"

echo "$OUT" | jq -e 'has("status") and has("checks") and (.checks|type=="array")' >/dev/null
echo "$OUT" | jq -e '.checks[] | select(.id=="catalog-docs-shape" and .status=="FAIL")' >/dev/null
echo "$OUT" | jq -e '.checks[] | select(.id=="docs-missing") | select(.message | contains("docs/repo-audit.md"))' >/dev/null
