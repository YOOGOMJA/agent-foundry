#!/bin/bash
# Orchestrator — 전체 파이프라인 실행
# Usage: ./scripts/orchestrate.sh
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_DIR="$SCRIPTS_DIR/../prompts"

# 프롬프트 파일 확인 (없으면 경고만, 에러 아님)
# 각 phase 프롬프트는 프로젝트 특화 내용이므로 직접 작성 필요.
# 참고: docs/templates/ 핸드오프 템플릿을 기반으로 prompts/ 아래에 작성.
MISSING_PROMPTS=()
for required in phase1-pm.md phase2a-architect.md phase2b-designer.md phase3-fe-developer.md phase3-be-developer.md phase4-tester.md; do
  if [ ! -f "$PROMPTS_DIR/$required" ]; then
    MISSING_PROMPTS+=("$required")
  fi
done

if [ ${#MISSING_PROMPTS[@]} -gt 0 ]; then
  echo "⚠️  Missing prompt files in prompts/:"
  for f in "${MISSING_PROMPTS[@]}"; do
    echo "   - $f"
  done
  echo ""
  echo "Create these files before running the pipeline."
  echo "See NEXT_STEPS.md for guidance."
  exit 1
fi

wait_for_gate() {
  local LABEL=$1
  echo "Waiting for gate: $LABEL (close the issue to approve)..."
  while true; do
    OPEN=$(gh issue list --label "$LABEL" --state open --json number --jq '.[0].number' 2>/dev/null)
    if [ -z "$OPEN" ]; then
      echo "Gate $LABEL approved!"
      return 0
    fi
    sleep 60
  done
}

echo "=== Phase 1: PM ==="
"$SCRIPTS_DIR/ralph-loop.sh" 5 5 "$PROMPTS_DIR/phase1-pm.md" pm
"$SCRIPTS_DIR/merge-worktree.sh" pm
gh issue create --title "Gate: PRD Review" \
  --body "PRD and screen specs ready for review. See docs/prd.md" \
  --label "gate:prd"
wait_for_gate "gate:prd"

echo "=== Phase 2A: Architecture ==="
"$SCRIPTS_DIR/ralph-loop.sh" 5 5 "$PROMPTS_DIR/phase2a-architect.md" architect
"$SCRIPTS_DIR/merge-worktree.sh" architect

echo "=== Phase 2B: Design System ==="
"$SCRIPTS_DIR/ralph-loop.sh" 5 5 "$PROMPTS_DIR/phase2b-designer.md" design
"$SCRIPTS_DIR/merge-worktree.sh" design

gh issue create --title "Gate: Architecture + Design Review" \
  --body "Architecture and design system ready for review." \
  --label "gate:design"
wait_for_gate "gate:design"

echo "=== Phase 2C: Implementation Plan ==="
claude -p "
  Read docs/architecture.md and docs/screen-spec.md.
  Create implementation plan → docs/plan.md.
  Extract FSD slice names → docs/plan-slices.txt (one per line).
" --dangerously-skip-permissions --max-turns 20 --max-budget-usd 3

echo "=== Phase 3: Implementation (FE parallel + BE) ==="
for slice in $(cat docs/plan-slices.txt); do
  "$SCRIPTS_DIR/ralph-loop.sh" 5 5 "$PROMPTS_DIR/phase3-fe-developer.md" "feat-$slice" &
done
"$SCRIPTS_DIR/ralph-loop.sh" 5 5 "$PROMPTS_DIR/phase3-be-developer.md" backend &
wait

for slice in $(cat docs/plan-slices.txt); do
  "$SCRIPTS_DIR/merge-worktree.sh" "feat-$slice"
done
"$SCRIPTS_DIR/merge-worktree.sh" backend

echo "=== Phase 4: Testing ==="
RETRY=0
MAX_RETRY=3
while [ $RETRY -lt $MAX_RETRY ]; do
  "$SCRIPTS_DIR/ralph-loop.sh" 3 5 "$PROMPTS_DIR/phase4-tester.md" test
  "$SCRIPTS_DIR/merge-worktree.sh" test

  if grep -q "PASSED" docs/test-report.md 2>/dev/null; then
    echo "All tests passed!"
    break
  fi

  RETRY=$((RETRY + 1))
  echo "Tests failed. Retry $RETRY/$MAX_RETRY..."
  claude -p "Read docs/test-report.md. Fix the failures." \
    --dangerously-skip-permissions --max-turns 30 --max-budget-usd 5
done

if [ $RETRY -ge $MAX_RETRY ]; then
  gh issue create --title "Escalation: Tests not passing" \
    --body "$(cat docs/test-report.md)" --label "escalation"
  exit 1
fi

echo "=== Phase 5A: Auto Review (Critic) ==="
# Ralph Loop 5회차를 Critic 모드로 실행
claude -p "
  You are an independent verifier. You have NO relationship to the code authors.
  Actively search for: spec violations, edge cases, security issues, performance bottlenecks,
  FSD public API violations, type mismatches between packages/types and actual API responses.
  Read docs/prd.md for acceptance criteria. Check each one against the implementation.
  If ALL checks pass, write CRITIC_PASSED to docs/critic-report.md.
  If issues found, write details to docs/critic-report.md with CRITIC_FAILED.
" --dangerously-skip-permissions --max-turns 20 --max-budget-usd 3

if ! grep -q "CRITIC_PASSED" docs/critic-report.md 2>/dev/null; then
  echo "Critic found issues. Fixing..."
  claude -p "Read docs/critic-report.md. Fix all issues found by the critic." \
    --dangerously-skip-permissions --max-turns 30 --max-budget-usd 5
  # Re-run critic once more
  claude -p "
    Independent verification pass 2. Read docs/critic-report.md for previous findings.
    Verify fixes. Write CRITIC_PASSED or CRITIC_FAILED to docs/critic-report.md.
  " --dangerously-skip-permissions --max-turns 15 --max-budget-usd 3
fi

echo "=== Phase 5B: PR Creation ==="
claude -p "
  Use superpowers requesting-code-review.
  Create PR with this structure:
  1. Change summary (1-2 paragraphs)
  2. Intent: which FR-XXX from docs/prd.md this implements
  3. Auto-verification evidence: build/test/lint results
  4. Critic review result from docs/critic-report.md
  5. Risk analysis: 'None' or specific concerns
  6. Screenshots if visual changes exist
" --dangerously-skip-permissions --max-turns 10 --max-budget-usd 2

echo "Pipeline complete. PR created for human review."
