#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

OUT="$(node "$ROOT/bin/agent-foundry.js" audit --format json)"

echo "$OUT" | jq -e 'has("status") and has("checks") and (.checks|type=="array")' >/dev/null
echo "$OUT" | jq -e '.checks[] | has("id") and has("status") and has("message")' >/dev/null

