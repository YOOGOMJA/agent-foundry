#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/manifests" "$TMP/templates/handoff"
cat > "$TMP/manifests/catalog.json" <<'JSON'
{
  "skills": [],
  "docs": [
    {
      "type": "goal",
      "source": "templates/handoff/goal.md",
      "destination": "docs/repo-write.md"
    },
    {
      "type": "broken",
      "source": "templates/handoff/goal.md"
    }
  ]
}
JSON
cat > "$TMP/templates/handoff/goal.md" <<'MD'
# Repo Goal Template

Repo-specific template sentinel.
MD

node "$ROOT/bin/agent-foundry.js" docs write goal --repo "$TMP" --yes >/dev/null

[[ -f "$TMP/docs/repo-write.md" ]]
grep -q "Repo Goal Template" "$TMP/docs/repo-write.md"
grep -q "Repo-specific template sentinel" "$TMP/docs/repo-write.md"
grep -q "TODO" "$TMP/docs/repo-write.md"

