#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- Test 1: --template fullstack --name test-project ---"
node "$ROOT/bin/agent-foundry.js"   --template fullstack   --name test-project   --output "$TMP/test1"

for f in   "CLAUDE.md"   ".mcp.json"   "scripts/orchestrate.sh"   "scripts/ralph-loop.sh"   "scripts/merge-worktree.sh"   "docs/templates/goal.md"   "docs/checklists/kickoff.md"   "docs/adr/ADR-000-template.md"   "NEXT_STEPS.md"   "skills-lock.json"   ".agents/skills/coding-conventions/SKILL.md"; do
  [[ -f "$TMP/test1/$f" ]] || { echo "MISSING: $f"; exit 1; }
done

grep -q "test-project" "$TMP/test1/CLAUDE.md" || { echo "FAIL: PROJECT_NAME not substituted"; exit 1; }
! grep -q "{{PROJECT_NAME}}" "$TMP/test1/CLAUDE.md" || { echo "FAIL: unreplaced {{PROJECT_NAME}}"; exit 1; }

node -e "
  const lock = JSON.parse(require('fs').readFileSync('$TMP/test1/skills-lock.json','utf8'));
  if (!lock.installedAt) throw new Error('installedAt missing');
  if (!lock.ref) throw new Error('ref missing');
  if (lock.template !== 'fullstack') throw new Error('template mismatch: ' + lock.template);
  if (!lock.skills.includes('coding-conventions')) throw new Error('coding-conventions missing from lock');
  console.log('skills-lock.json OK');
"

echo "--- Test 2: --skills only ---"
node "$ROOT/bin/agent-foundry.js"   --skills coding-conventions   --name test-project   --output "$TMP/test2"

[[ -f "$TMP/test2/.agents/skills/coding-conventions/SKILL.md" ]] || { echo "MISSING: skill file"; exit 1; }
[[ ! -f "$TMP/test2/CLAUDE.md" ]] || { echo "FAIL: CLAUDE.md should not exist in skills-only mode"; exit 1; }

echo "--- Test 3: no flags = error ---"
error_output=$(node "$ROOT/bin/agent-foundry.js" --output "$TMP/test3" 2>&1) || true
echo "$error_output" | grep -qi "error\|required" || { echo "FAIL: expected error message when no flags given"; exit 1; }

echo "--- Test 4: --name defaults to directory name ---"
mkdir -p "$TMP/myproject"
(cd "$TMP/myproject" && node "$ROOT/bin/agent-foundry.js" --skills coding-conventions)
[[ -f "$TMP/myproject/.agents/skills/coding-conventions/SKILL.md" ]] || { echo "MISSING: default output skill"; exit 1; }
node -e "
  const lock = JSON.parse(require('fs').readFileSync('$TMP/myproject/skills-lock.json','utf8'));
  if (lock.template !== null) throw new Error('template should be null, got: ' + lock.template);
  if (!lock.skills.includes('coding-conventions')) throw new Error('skills missing from lock');
  console.log('Test 4 lock OK');
"

echo "OK: CLI"
