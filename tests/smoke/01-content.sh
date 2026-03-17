#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

check() { [[ -f "$ROOT/$1" ]] || { echo "MISSING: $1"; exit 1; }; }

# coding-conventions
check "skills/coding-conventions/SKILL.md"
check "skills/coding-conventions/references/naming.md"
check "skills/coding-conventions/references/fp-patterns.md"
check "skills/coding-conventions/references/fsd-public-api.md"
check "skills/coding-conventions/references/zustand-patterns.md"
check "skills/coding-conventions/references/xstate-patterns.md"

grep -q "^name:" "$ROOT/skills/coding-conventions/SKILL.md" || { echo "FAIL: SKILL.md missing 'name:' frontmatter"; exit 1; }
grep -q "^description:" "$ROOT/skills/coding-conventions/SKILL.md" || { echo "FAIL: SKILL.md missing 'description:' frontmatter"; exit 1; }

echo "OK: coding-conventions skill"
