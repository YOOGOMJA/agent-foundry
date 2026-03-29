#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/manifests"
mkdir -p "$TMP/templates/handoff"
cp "$ROOT/manifests/catalog.json" "$TMP/manifests/catalog.json"
cat > "$TMP/templates/handoff/goal.md" <<'MD'
# Project Goal Template

This template lives in the project root and must win over the tool fallback.
MD

(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" docs write goal --yes >/dev/null)

[[ -f "$TMP/docs/goal.md" ]]
grep -q "Project Goal Template" "$TMP/docs/goal.md"
grep -q "project root and must win over the tool fallback" "$TMP/docs/goal.md"
grep -q "TODO" "$TMP/docs/goal.md"
