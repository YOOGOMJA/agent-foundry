#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

node "$ROOT/bin/agent-foundry.js" skills search >/dev/null
node "$ROOT/bin/agent-foundry.js" skills search --source all >/dev/null
ORDER_A="$(node "$ROOT/bin/agent-foundry.js" skills search --source all coding)"
ORDER_B="$(node "$ROOT/bin/agent-foundry.js" skills search coding --source all)"
[[ "$ORDER_A" == "$ORDER_B" ]]
node "$ROOT/bin/agent-foundry.js" audit --format json >/dev/null
node "$ROOT/bin/agent-foundry.js" docs suggest >/dev/null

if node "$ROOT/bin/agent-foundry.js" nope 2>/dev/null; then
  echo "expected top-level unknown command to fail"
  exit 1
fi

if node "$ROOT/bin/agent-foundry.js" skills nope 2>/dev/null; then
  echo "expected nested unknown command to fail"
  exit 1
fi
