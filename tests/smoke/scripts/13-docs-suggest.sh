#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/manifests"
cp "$ROOT/manifests/catalog.json" "$TMP/manifests/catalog.json"

OUT="$(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" docs suggest)"

echo "$OUT" | grep -q "docs/goal.md"
echo "$OUT" | grep -q "templates/handoff/goal.md"

