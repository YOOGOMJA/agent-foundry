#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ESCAPE_BASENAME="escape-$(date +%s)-$RANDOM.md"
PARENT_DIR="$(dirname "$TMP")"
ESCAPE_PATH="$PARENT_DIR/$ESCAPE_BASENAME"

mkdir -p "$TMP/manifests"
cat > "$TMP/manifests/catalog.json" <<JSON
{
  "skills": [],
  "docs": [
    {
      "type": "goal",
      "source": "../outside-secret.md",
      "destination": "../$ESCAPE_BASENAME"
    }
  ]
}
JSON

echo "secret" > "$PARENT_DIR/outside-secret.md"

if node "$ROOT/bin/agent-foundry.js" docs write goal --repo "$TMP" --yes 2>/dev/null; then
  echo "expected traversal doc mapping to fail"
  exit 1
fi

[[ ! -f "$ESCAPE_PATH" ]]
