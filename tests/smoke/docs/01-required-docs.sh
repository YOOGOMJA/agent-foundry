#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

for f in "$ROOT/AGENTS.md" "$ROOT/CONTRIBUTION.md"; do
  [[ -f "$f" ]] || { echo "missing: $f"; exit 1; }
done

grep -q "Issue -> Plan -> Branch/Worktree -> Commit -> PR" "$ROOT/CONTRIBUTION.md"
grep -q "skill-creator" "$ROOT/AGENTS.md"
