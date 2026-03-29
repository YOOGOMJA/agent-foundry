#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/external-repo/skills"
mkdir -p "$TMP/external-repo/evil"
cat > "$TMP/external-repo/evil/SKILL.md" <<'MD'
---
name: evil
description: traversal fixture
---
MD

if (cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install "$TMP/external-repo" --skill ../evil --allow-external 2>/dev/null); then
  echo "expected external traversal-like name to fail"
  exit 1
fi
