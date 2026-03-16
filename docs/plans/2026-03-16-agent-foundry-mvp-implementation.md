# Agent-Foundry MVP (Skills Hub) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 새 프로젝트에서 고정 버전 기반으로 스킬을 선택 설치하고 `AGENTS.md`를 자동 생성하는 공개형 Skills Hub MVP를 구축한다.

**Architecture:** 저장소 루트에 `skills/`, `templates/agents/`, `manifests/`, `scripts/`를 두고, `bootstrap-project.sh`가 설치/생성/lock 기록을 오케스트레이션한다. 버전은 태그 기반 고정 전략을 사용하고 프로젝트에는 `skills-lock.json`을 기록한다. 문서 운영은 한국어 고정, 작업 흐름은 `Issue -> Plan -> Branch/Worktree -> Commit -> PR`로 통일한다.

**Tech Stack:** Bash, Git/GitHub CLI, Markdown, JSON(manifest/lock)

---

## 공통 실행 규칙

- 관련 스킬: `@test-driven-development`, `@verification-before-completion`, `@skill-creator`
- 각 Task는 반드시 테스트 실패를 먼저 확인한다.
- 각 Task 완료 시점마다 작은 커밋을 만든다.
- 모든 문서는 한국어로 작성한다.

### Task 1: 기본 거버넌스 문서 추가 (`AGENTS.md`, `CONTRIBUTION.md`)

**Files:**
- Create: `AGENTS.md`
- Create: `CONTRIBUTION.md`
- Test: `tests/smoke/docs/01-required-docs.sh`

**Step 1: 실패 테스트 작성**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

for f in "$ROOT/AGENTS.md" "$ROOT/CONTRIBUTION.md"; do
  [[ -f "$f" ]] || { echo "missing: $f"; exit 1; }
done

grep -q "Issue -> Plan -> Branch/Worktree -> Commit -> PR" "$ROOT/CONTRIBUTION.md"
grep -q "skill-creator" "$ROOT/AGENTS.md"
```

**Step 2: 실패 확인**

Run: `bash tests/smoke/docs/01-required-docs.sh`  
Expected: `missing:` 메시지와 함께 FAIL

**Step 3: 최소 구현**

`AGENTS.md` 최소 본문 예시:

```md
# Agent Foundry 운영 규칙

## 목적
- 도메인 독립 스킬 허브 운영

## 스킬 작성 규칙
- 새 스킬 생성/수정은 `skill-creator` 우선 사용
```

`CONTRIBUTION.md` 최소 본문 예시:

```md
# 기여 가이드

## 기본 흐름
Issue -> Plan -> Branch/Worktree -> Commit -> PR
```

**Step 4: 통과 확인**

Run: `bash tests/smoke/docs/01-required-docs.sh`  
Expected: PASS(출력 없음, 종료코드 0)

**Step 5: 커밋**

```bash
git add AGENTS.md CONTRIBUTION.md tests/smoke/docs/01-required-docs.sh
git commit -m "docs: 기본 운영 문서와 문서 스모크 테스트 추가"
```

### Task 2: 스킬/템플릿/매니페스트 초기 구조 작성

**Files:**
- Create: `skills/README.md`
- Create: `templates/agents/base.md`
- Create: `templates/agents/frontend.md`
- Create: `templates/agents/fullstack.md`
- Create: `manifests/skills.json`
- Test: `tests/smoke/manifest/01-manifest-shape.sh`

**Step 1: 실패 테스트 작성**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

[[ -f "$ROOT/manifests/skills.json" ]] || exit 1
jq -e '.version and .skills and (.skills | type == "array")' "$ROOT/manifests/skills.json" >/dev/null
for t in base frontend fullstack; do
  [[ -f "$ROOT/templates/agents/$t.md" ]] || exit 1
done
```

**Step 2: 실패 확인**

Run: `bash tests/smoke/manifest/01-manifest-shape.sh`  
Expected: 파일 없음으로 FAIL

**Step 3: 최소 구현**

`manifests/skills.json` 예시:

```json
{
  "version": "0.1.0",
  "skills": [
    {
      "name": "vercel-react-best-practices",
      "path": "skills/vercel-react-best-practices",
      "description": "React/Next.js 성능 최적화 가이드"
    }
  ]
}
```

템플릿은 제목/목적/스킬 목록 슬롯만 가진 최소 형태로 시작한다.

**Step 4: 통과 확인**

Run: `bash tests/smoke/manifest/01-manifest-shape.sh`  
Expected: PASS

**Step 5: 커밋**

```bash
git add skills/README.md templates/agents/*.md manifests/skills.json tests/smoke/manifest/01-manifest-shape.sh
git commit -m "feat: 스킬 허브 기본 구조와 매니페스트 추가"
```

### Task 3: `install-skill.sh` 구현 (선택 스킬 설치)

**Files:**
- Create: `scripts/install-skill.sh`
- Test: `tests/smoke/scripts/01-install-skill.sh`

**Step 1: 실패 테스트 작성**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/scripts/install-skill.sh" \
  --repo-root "$ROOT" \
  --target "$TMP" \
  --skill vercel-react-best-practices

[[ -f "$TMP/.agents/skills/vercel-react-best-practices/SKILL.md" ]]
```

**Step 2: 실패 확인**

Run: `bash tests/smoke/scripts/01-install-skill.sh`  
Expected: 스크립트 부재 또는 설치 실패로 FAIL

**Step 3: 최소 구현**

핵심 구현 포인트:
- 인자 파싱: `--repo-root`, `--target`, `--skill`
- `manifests/skills.json`에서 스킬 경로 조회(`jq`)
- `cp -R`로 대상 프로젝트의 `.agents/skills/<name>` 복사
- 이미 존재 시 `--force` 없으면 실패

**Step 4: 통과 확인**

Run: `bash tests/smoke/scripts/01-install-skill.sh`  
Expected: PASS

**Step 5: 커밋**

```bash
git add scripts/install-skill.sh tests/smoke/scripts/01-install-skill.sh
git commit -m "feat: 스킬 선택 설치 스크립트 구현"
```

### Task 4: `bootstrap-project.sh` 구현 (`AGENTS.md` 생성 + lock 기록)

**Files:**
- Create: `scripts/bootstrap-project.sh`
- Test: `tests/smoke/scripts/02-bootstrap.sh`

**Step 1: 실패 테스트 작성**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/scripts/bootstrap-project.sh" \
  --repo-root "$ROOT" \
  --target "$TMP" \
  --template frontend \
  --skills vercel-react-best-practices

[[ -f "$TMP/AGENTS.md" ]]
[[ -f "$TMP/skills-lock.json" ]]
[[ -f "$TMP/.agents/skills/vercel-react-best-practices/SKILL.md" ]]
```

**Step 2: 실패 확인**

Run: `bash tests/smoke/scripts/02-bootstrap.sh`  
Expected: 스크립트 부재로 FAIL

**Step 3: 최소 구현**

핵심 구현 포인트:
- 템플릿 파일(`templates/agents/<template>.md`)을 대상 `AGENTS.md`로 복사
- `--skills`를 쉼표 분리하여 `install-skill.sh` 반복 호출
- `skills-lock.json` 최소 구조 기록

`skills-lock.json` 예시:

```json
{
  "hub": "YOOGOMJA/agent-foundry",
  "version": "v0.1.0",
  "installedAt": "2026-03-16T00:00:00Z",
  "skills": ["vercel-react-best-practices"]
}
```

**Step 4: 통과 확인**

Run: `bash tests/smoke/scripts/02-bootstrap.sh`  
Expected: PASS

**Step 5: 커밋**

```bash
git add scripts/bootstrap-project.sh tests/smoke/scripts/02-bootstrap.sh
git commit -m "feat: 프로젝트 부트스트랩과 lock 생성 구현"
```

### Task 5: `update-skills.sh` 구현 (lock 기반 수동 업데이트)

**Files:**
- Create: `scripts/update-skills.sh`
- Test: `tests/smoke/scripts/03-update-skills.sh`

**Step 1: 실패 테스트 작성**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/skills-lock.json" <<'JSON'
{
  "hub": "YOOGOMJA/agent-foundry",
  "version": "v0.1.0",
  "skills": ["vercel-react-best-practices"]
}
JSON

bash "$ROOT/scripts/update-skills.sh" --repo-root "$ROOT" --target "$TMP"
[[ -f "$TMP/.agents/skills/vercel-react-best-practices/SKILL.md" ]]
```

**Step 2: 실패 확인**

Run: `bash tests/smoke/scripts/03-update-skills.sh`  
Expected: 스크립트 부재로 FAIL

**Step 3: 최소 구현**

핵심 구현 포인트:
- 대상 프로젝트의 `skills-lock.json` 필수 검사
- lock의 `skills[]`를 읽어 재설치 수행
- lock 버전이 manifest와 불일치하면 중단하고 안내 메시지 출력

**Step 4: 통과 확인**

Run: `bash tests/smoke/scripts/03-update-skills.sh`  
Expected: PASS

**Step 5: 커밋**

```bash
git add scripts/update-skills.sh tests/smoke/scripts/03-update-skills.sh
git commit -m "feat: lock 기반 스킬 수동 업데이트 스크립트 구현"
```

### Task 6: ADR 및 계획 운영 문서 추가

**Files:**
- Create: `docs/adr/README.md`
- Create: `docs/adr/0001-skills-hub-distribution.md`
- Create: `docs/adr/0002-version-lock-policy.md`
- Create: `docs/plans/README.md`
- Create: `docs/plans/TEMPLATE.md`
- Test: `tests/smoke/docs/02-adr-and-plan-docs.sh`

**Step 1: 실패 테스트 작성**

```bash
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
```

**Step 2: 실패 확인**

Run: `bash tests/smoke/docs/02-adr-and-plan-docs.sh`  
Expected: 누락 파일로 FAIL

**Step 3: 최소 구현**

문서 핵심 내용:
- ADR-0001: 공개 허브 + 선택 설치 모델 채택 근거
- ADR-0002: 고정 버전 + lock + 수동 업데이트 정책
- `docs/plans/TEMPLATE.md`: 한국어 구현 계획 템플릿

**Step 4: 통과 확인**

Run: `bash tests/smoke/docs/02-adr-and-plan-docs.sh`  
Expected: PASS

**Step 5: 커밋**

```bash
git add docs/adr docs/plans/README.md docs/plans/TEMPLATE.md tests/smoke/docs/02-adr-and-plan-docs.sh
git commit -m "docs: ADR 및 계획 운영 문서 체계 추가"
```

### Task 7: 전체 스모크 실행과 완료 검증

**Files:**
- Create: `tests/smoke/run-all.sh`
- Modify: `README.md`

**Step 1: 실패 테스트 작성**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

bash "$ROOT/tests/smoke/docs/01-required-docs.sh"
bash "$ROOT/tests/smoke/manifest/01-manifest-shape.sh"
bash "$ROOT/tests/smoke/scripts/01-install-skill.sh"
bash "$ROOT/tests/smoke/scripts/02-bootstrap.sh"
bash "$ROOT/tests/smoke/scripts/03-update-skills.sh"
bash "$ROOT/tests/smoke/docs/02-adr-and-plan-docs.sh"
```

**Step 2: 실패 확인**

Run: `bash tests/smoke/run-all.sh`  
Expected: 이전 Task 미완료 상태에서는 FAIL, 전체 완료 후 PASS

**Step 3: 최소 구현**

- `README.md`에 아래 항목 추가:
  - MVP 목적
  - 빠른 시작(bootstrap 명령)
  - 버전 고정/업데이트 정책

**Step 4: 통과 확인**

Run: `bash tests/smoke/run-all.sh`  
Expected: PASS

추가 검증:
- `git status --short` (의도한 파일만 변경 확인)
- `bash tests/smoke/run-all.sh` 재실행 (idempotent 확인)

**Step 5: 커밋**

```bash
git add tests/smoke/run-all.sh README.md
git commit -m "test: 전체 스모크 실행기와 빠른 시작 문서 추가"
```

## 완료 기준

- 새 빈 프로젝트에 대해 `bootstrap-project.sh` 1회 실행으로 스킬 설치, `AGENTS.md`, `skills-lock.json` 생성이 완료된다.
- 같은 lock으로 재실행 시 동일 결과가 재현된다.
- 문서/정책/템플릿/스크립트가 모두 한국어 운영 기준을 따른다.
- 새 스킬 추가 규칙에 `skill-creator` 우선 사용이 명시되어 있다.
