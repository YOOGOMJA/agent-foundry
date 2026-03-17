#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

bash "$ROOT/tests/smoke/01-content.sh"
bash "$ROOT/tests/smoke/02-manifests.sh"
bash "$ROOT/tests/smoke/03-cli.sh"

echo ""
echo "============================="
echo "  ALL SMOKE TESTS PASSED"
echo "============================="
