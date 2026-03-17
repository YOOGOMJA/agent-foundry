#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
for f in \
  "$ROOT/docs/adr/README.md" \
  "$ROOT/docs/adr/0001-skills-hub-distribution.md" \
  "$ROOT/docs/adr/0002-version-lock-policy.md" \
  "$ROOT/docs/plans/README.md" \
  "$ROOT/docs/plans/TEMPLATE.md"; do
  [[ -f "$f" ]] || { echo "missing: $f"; exit 1; }
done
