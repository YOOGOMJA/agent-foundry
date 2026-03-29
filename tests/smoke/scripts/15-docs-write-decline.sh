#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/manifests" "$TMP/templates/handoff"
cp "$ROOT/manifests/catalog.json" "$TMP/manifests/catalog.json"
cat > "$TMP/templates/handoff/goal.md" <<'MD'
# Project Goal Template
MD

if ! printf 'n\n' | (cd "$TMP" && node "$ROOT/bin/agent-foundry.js" docs write goal); then
  echo "expected docs write to succeed after decline"
  exit 1
fi

[[ ! -f "$TMP/docs/goal.md" ]]
