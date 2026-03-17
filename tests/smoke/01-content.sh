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

# templates
check "templates/CLAUDE.md.tmpl"
check "templates/mcp.json.tmpl"
check "templates/scripts/orchestrate.sh"
check "templates/scripts/ralph-loop.sh"
check "templates/scripts/merge-worktree.sh"
check "templates/handoff/goal.md"
check "templates/handoff/prd.md"
check "templates/handoff/screen-spec.md"
check "templates/handoff/api-spec.md"
check "templates/handoff/architecture.md"

grep -q "{{PROJECT_NAME}}" "$ROOT/templates/CLAUDE.md.tmpl" || { echo "FAIL: CLAUDE.md.tmpl missing {{PROJECT_NAME}}"; exit 1; }
grep -q "{{GITHUB_REPO}}" "$ROOT/templates/mcp.json.tmpl" || { echo "FAIL: mcp.json.tmpl missing {{GITHUB_REPO}}"; exit 1; }

echo "OK: templates"
