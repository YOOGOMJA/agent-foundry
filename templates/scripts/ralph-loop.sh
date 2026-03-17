#!/bin/bash
# Ralph Loop — 품질 수렴 반복
# Usage: ./scripts/ralph-loop.sh <max_iter> <budget> "<prompt_file>" <worktree_name>
set -euo pipefail

MAX_ITER=${1:-5}
BUDGET=${2:-3}
PROMPT_FILE=$3
WORKTREE_NAME=${4:-review}
WORKTREE_PATH=".claude/worktrees/$WORKTREE_NAME"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: prompt file not found: $PROMPT_FILE"
  exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")

for i in $(seq 1 $MAX_ITER); do
  echo "=== Ralph Loop iteration $i / $MAX_ITER ==="

  # 마지막 반복은 Critic 모드
  if [ "$i" -eq "$MAX_ITER" ]; then
    ITER_PROMPT="You are an INDEPENDENT VERIFIER. Forget all previous context about authoring this code.
    Actively search for: spec violations, edge cases, security issues, performance bottlenecks.
    Read .ralph/progress.txt for previous state.
    If ALL checks pass, write CONVERGED to .ralph/progress.txt.
    If issues found, describe them in .ralph/progress.txt (do NOT write CONVERGED)."
  else
    ITER_PROMPT="$PROMPT

    IMPORTANT: Write progress to .ralph/progress.txt (relative to repo root).
    Read .ralph/progress.txt for previous state if it exists.
    Review and improve. Update .ralph/progress.txt with findings.
    If no issues remain, write CONVERGED to .ralph/progress.txt."
  fi

  claude -p "$ITER_PROMPT" \
    --worktree "$WORKTREE_NAME" \
    --dangerously-skip-permissions \
    --max-turns 20 \
    --max-budget-usd "$BUDGET"

  if [ -f "$WORKTREE_PATH/.ralph/progress.txt" ] && \
     grep -q "CONVERGED" "$WORKTREE_PATH/.ralph/progress.txt"; then
    echo "Converged at iteration $i"
    (cd "$WORKTREE_PATH" && git add -A && git commit -m "ralph: converged at iteration $i" 2>/dev/null || true)
    exit 0
  fi
done

echo "Did not converge after $MAX_ITER iterations. Escalating."
gh issue create \
  --title "Ralph Loop escalation: $WORKTREE_NAME" \
  --body "Did not converge after $MAX_ITER iterations." \
  --label "escalation" 2>/dev/null || echo "Warning: could not create issue"
exit 1
