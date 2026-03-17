# Greenfield AI Setup Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `npx github:kyeongsoo-yoo/agent-foundry --template fullstack --name my-app` 한 줄로 새 프로젝트의 AI 운영 환경을 완전히 세팅한다.

**Architecture:** 두 레이어로 구성. 컨텐츠 레이어(skills, templates, scripts, checklists)는 autonomous-dev-pipeline 노트에서 포팅하고, 전달 레이어(`bin/agent-foundry.js`)는 Node built-in만 사용하는 ~100줄 CLI다. `npx github:` 실행 시 전체 레포가 로컬에 다운로드되므로 CLI는 GitHub API fetch 없이 `__dirname` 기준 로컬 파일을 읽어 대상 디렉토리에 복사한다. (스펙의 실행 흐름 다이어그램은 이전 설계를 반영하며, 이 플랜이 그것을 대체한다.)

**Tech Stack:** Node.js 18+ (built-in `fs`, `path`, `process`), Bash (templates/scripts), Markdown (content), JSON (manifests, skills-lock)

**Spec:** `docs/superpowers/specs/2026-03-17-agent-foundry-greenfield-ai-setup-design.md`

---

## 사전 조건

- Node.js 18+ 설치 확인: `node --version`
- `gh` CLI 인증 확인: `gh auth status`
- macOS 환경: `base64` 디코드는 `-D` 플래그 사용 (`-d` 아님)

---

## 파일 맵

### 생성 파일 (컨텐츠 레이어)

| 파일 | 출처 |
|------|------|
| `skills/coding-conventions/SKILL.md` | autonomous-dev-pipeline 포팅 |
| `skills/coding-conventions/references/naming.md` | 포팅 |
| `skills/coding-conventions/references/fp-patterns.md` | 포팅 |
| `skills/coding-conventions/references/fsd-public-api.md` | 포팅 |
| `skills/coding-conventions/references/zustand-patterns.md` | 포팅 |
| `skills/coding-conventions/references/xstate-patterns.md` | 포팅 |
| `templates/CLAUDE.md.tmpl` | 포팅 — `{{PROJECT_NAME}}` 포함 |
| `templates/mcp.json.tmpl` | 포팅 — `{{GITHUB_REPO}}` 포함 |
| `templates/scripts/orchestrate.sh` | 포팅 |
| `templates/scripts/ralph-loop.sh` | 포팅 |
| `templates/scripts/merge-worktree.sh` | 포팅 |
| `templates/handoff/goal.md` | 포팅 |
| `templates/handoff/prd.md` | 포팅 |
| `templates/handoff/screen-spec.md` | 포팅 |
| `templates/handoff/api-spec.md` | 포팅 |
| `templates/handoff/architecture.md` | 포팅 |
| `templates/NEXT_STEPS/fullstack.md` | 신규 작성 |
| `checklists/kickoff.md` | 포팅 |
| `checklists/review-criteria.md` | 포팅 |
| `adr/ADR-000-template.md` | 신규 작성 |
| `docs/references/toolchain-catalog.md` | 포팅 (내부 참고, 대상 프로젝트 복사 안 함) |

### 생성 파일 (전달 레이어)

| 파일 | 비고 |
|------|------|
| `package.json` | bin 엔트리, 의존성 없음 |
| `bin/agent-foundry.js` | ~100줄, Node built-in만 |
| `manifests/templates.json` | fullstack 파일 목록 |
| `manifests/skills.json` | 등록 스킬 목록 |

### CLI 플래그

| 플래그 | 필수 | 설명 |
|--------|------|------|
| `--template` | 하나 이상 필수 (동시 사용 가능) | 템플릿 이름 (예: `fullstack`) |
| `--skills` | 하나 이상 필수 (동시 사용 가능) | 스킬 이름 콤마 구분 (예: `coding-conventions`) |
| `--name` | 선택 | 프로젝트 이름. 없으면 현재 디렉토리 이름 사용 |
| `--repo` | 선택 | GitHub repo 주소. 없으면 빈칸 |
| `--output` | 선택 (테스트용) | 출력 디렉토리 override. 없으면 `process.cwd()` |

### 테스트 파일

| 파일 | 검증 대상 |
|------|----------|
| `tests/smoke/01-content.sh` | 컨텐츠 파일 존재 여부 |
| `tests/smoke/02-manifests.sh` | JSON 구조 유효성 |
| `tests/smoke/03-cli.sh` | CLI end-to-end 실행 |
| `tests/smoke/run-all.sh` | 전체 실행 |

---

## Task 1: coding-conventions 스킬 포팅

**Files:**
- Create: `skills/coding-conventions/SKILL.md`
- Create: `skills/coding-conventions/references/naming.md`
- Create: `skills/coding-conventions/references/fp-patterns.md`
- Create: `skills/coding-conventions/references/fsd-public-api.md`
- Create: `skills/coding-conventions/references/zustand-patterns.md`
- Create: `skills/coding-conventions/references/xstate-patterns.md`
- Create: `tests/smoke/01-content.sh`

- [ ] **Step 1: 테스트 작성**

```bash
mkdir -p tests/smoke
cat > tests/smoke/01-content.sh << 'SCRIPT'
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
SCRIPT
chmod +x tests/smoke/01-content.sh
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `MISSING: skills/coding-conventions/SKILL.md`

- [ ] **Step 3: 프라이빗 레포 접근 확인**

```bash
gh api repos/kyeongsoo-dable/obsidian-personal-notes --jq '.private' || {
  echo "ERROR: Cannot access obsidian-personal-notes. Check gh auth and repo scope."
  exit 1
}
```

- [ ] **Step 4: GitHub에서 파일 fetch 후 생성 (macOS: base64 -D)**

```bash
BASE="repos/kyeongsoo-dable/obsidian-personal-notes/contents/30_Resources/ideation/autonomous-dev-pipeline"

mkdir -p skills/coding-conventions/references

gh api "$BASE/skills/coding-conventions/SKILL.md" --jq '.content' | base64 -D > skills/coding-conventions/SKILL.md

for f in naming fp-patterns fsd-public-api zustand-patterns xstate-patterns; do
  gh api "$BASE/skills/coding-conventions/references/$f.md" --jq '.content' | base64 -D \
    > "skills/coding-conventions/references/$f.md"
done
```

- [ ] **Step 5: 테스트 통과 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `OK: coding-conventions skill`

- [ ] **Step 6: 커밋**

```bash
git add skills/ tests/smoke/01-content.sh
git commit -m "feat: coding-conventions 스킬 포팅"
```

---

## Task 2: 템플릿 파일 포팅

**Files:**
- Create: `templates/CLAUDE.md.tmpl`
- Create: `templates/mcp.json.tmpl`
- Create: `templates/scripts/orchestrate.sh`
- Create: `templates/scripts/ralph-loop.sh`
- Create: `templates/scripts/merge-worktree.sh`
- Create: `templates/handoff/goal.md`
- Create: `templates/handoff/prd.md`
- Create: `templates/handoff/screen-spec.md`
- Create: `templates/handoff/api-spec.md`
- Create: `templates/handoff/architecture.md`
- Modify: `tests/smoke/01-content.sh`

- [ ] **Step 1: 테스트 확장 (마지막 echo 행을 교체)**

`tests/smoke/01-content.sh`의 마지막 `echo "OK: coding-conventions skill"` 행을 찾아 아래로 교체:

```bash
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
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `MISSING: templates/CLAUDE.md.tmpl`

- [ ] **Step 3: GitHub에서 fetch 후 생성**

```bash
BASE="repos/kyeongsoo-dable/obsidian-personal-notes/contents/30_Resources/ideation/autonomous-dev-pipeline"

mkdir -p templates/scripts templates/handoff

gh api "$BASE/templates/CLAUDE.md.tmpl" --jq '.content' | base64 -D > templates/CLAUDE.md.tmpl
gh api "$BASE/templates/mcp.json.tmpl" --jq '.content' | base64 -D > templates/mcp.json.tmpl

for f in orchestrate.sh ralph-loop.sh merge-worktree.sh; do
  gh api "$BASE/templates/scripts/$f" --jq '.content' | base64 -D > "templates/scripts/$f"
  chmod +x "templates/scripts/$f"
done

for f in goal.md prd.md screen-spec.md api-spec.md architecture.md; do
  gh api "$BASE/templates/handoff/$f" --jq '.content' | base64 -D > "templates/handoff/$f"
done
```

**검증**: `CLAUDE.md.tmpl`에 `{{PROJECT_NAME}}`가 없으면 첫 줄을 수동으로 수정:

```bash
head -1 templates/CLAUDE.md.tmpl
# "# CLAUDE.md" 등으로 시작하면 {{PROJECT_NAME}} 추가
# 예: "# CLAUDE.md — {{PROJECT_NAME}}"
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `OK: templates`

- [ ] **Step 5: 커밋**

```bash
git add templates/ tests/smoke/01-content.sh
git commit -m "feat: 파이프라인 템플릿 파일 포팅"
```

---

## Task 3: 체크리스트, ADR 템플릿, 내부 참고 문서

**Files:**
- Create: `checklists/kickoff.md`
- Create: `checklists/review-criteria.md`
- Create: `adr/ADR-000-template.md`
- Create: `docs/references/toolchain-catalog.md`
- Modify: `tests/smoke/01-content.sh`

- [ ] **Step 1: 테스트 확장 (마지막 echo 행 교체)**

`tests/smoke/01-content.sh`의 마지막 `echo "OK: templates"` 행을 아래로 교체:

```bash
echo "OK: templates"

# checklists & adr
check "checklists/kickoff.md"
check "checklists/review-criteria.md"
check "adr/ADR-000-template.md"
check "docs/references/toolchain-catalog.md"

echo "OK: checklists & adr"
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `MISSING: checklists/kickoff.md`

- [ ] **Step 3: GitHub에서 fetch 후 생성**

```bash
BASE="repos/kyeongsoo-dable/obsidian-personal-notes/contents/30_Resources/ideation/autonomous-dev-pipeline"

mkdir -p checklists adr docs/references

for f in kickoff.md review-criteria.md; do
  gh api "$BASE/checklists/$f" --jq '.content' | base64 -D > "checklists/$f"
done

gh api "$BASE/toolchain-catalog.md" --jq '.content' | base64 -D > docs/references/toolchain-catalog.md
```

`adr/ADR-000-template.md` 신규 작성:

```bash
cat > adr/ADR-000-template.md << 'EOF'
# ADR-000: [결정 제목]

> 날짜: YYYY-MM-DD | 상태: Proposed / Accepted / Deprecated

## 컨텍스트

[왜 이 결정이 필요했는가]

## 결정

[무엇을 결정했는가]

## 근거

[왜 이 선택인가. 대안과 비교]

## 결과

[이 결정이 만드는 영향. 트레이드오프]
EOF
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `OK: checklists & adr`

- [ ] **Step 5: 커밋**

```bash
git add checklists/ adr/ docs/references/ tests/smoke/01-content.sh
git commit -m "feat: 체크리스트, ADR 템플릿, 툴체인 카탈로그 추가"
```

---

## Task 4: NEXT_STEPS/fullstack.md 작성

**Files:**
- Create: `templates/NEXT_STEPS/fullstack.md`
- Modify: `tests/smoke/01-content.sh`

- [ ] **Step 1: 테스트 확장 (마지막 echo 행 교체)**

`tests/smoke/01-content.sh`의 마지막 `echo "OK: checklists & adr"` 행을 아래로 교체:

```bash
echo "OK: checklists & adr"

# NEXT_STEPS
check "templates/NEXT_STEPS/fullstack.md"
grep -q "claude plugin marketplace add" "$ROOT/templates/NEXT_STEPS/fullstack.md" || { echo "FAIL: NEXT_STEPS missing plugin commands"; exit 1; }
grep -q "orchestrate.sh" "$ROOT/templates/NEXT_STEPS/fullstack.md" || { echo "FAIL: NEXT_STEPS missing orchestrate.sh"; exit 1; }

echo "OK: NEXT_STEPS"
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `MISSING: templates/NEXT_STEPS/fullstack.md`

- [ ] **Step 3: 파일 작성**

```bash
mkdir -p templates/NEXT_STEPS
cat > templates/NEXT_STEPS/fullstack.md << 'EOF'
# Next Steps — {{PROJECT_NAME}}

agent-foundry로 풀스택 프로젝트 환경이 세팅됐습니다.
아래 순서대로 진행하세요.

---

## 1. 플러그인 & 스킬 설치

~~~bash
claude plugin marketplace add phuryn/pm-skills
claude plugin marketplace add zircote/adr
npx skills add feature-sliced/skills
npx skills add https://github.com/wshobson/agents --skill tailwind-design-system
npx skills add https://github.com/anthropics/skills --skill webapp-testing
~~~

## 2. 환경 설정

- [ ] `.mcp.json`에 `GITHUB_TOKEN` 입력
- [ ] `ANTHROPIC_API_KEY` 환경변수 설정

~~~bash
export ANTHROPIC_API_KEY=sk-ant-...
~~~

- [ ] `gh auth status` 로 GitHub CLI 인증 확인

## 3. 실행 권한 부여

~~~bash
chmod +x scripts/orchestrate.sh scripts/ralph-loop.sh scripts/merge-worktree.sh
~~~

## 4. 목표 작성 후 파이프라인 시작

~~~bash
cp docs/templates/goal.md docs/goal.md
# docs/goal.md 편집 후:
./scripts/orchestrate.sh
~~~

---

## 설치된 항목

- **스킬**: `.agents/skills/coding-conventions/` — TS/React 코딩 컨벤션
- **CLAUDE.md**: 프로젝트 AI 운영 규칙
- **scripts/**: 파이프라인 오케스트레이션 스크립트
- **docs/checklists/**: kickoff, review-criteria
- **docs/adr/**: ADR-000 템플릿

설치 정보: `skills-lock.json` 참조
EOF
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
bash tests/smoke/01-content.sh
```
Expected: `OK: NEXT_STEPS`

- [ ] **Step 5: 커밋**

```bash
git add templates/NEXT_STEPS/ tests/smoke/01-content.sh
git commit -m "feat: fullstack NEXT_STEPS 가이드 작성"
```

---

## Task 5: 매니페스트 작성

**Files:**
- Create: `manifests/templates.json`
- Create: `manifests/skills.json`
- Create: `tests/smoke/02-manifests.sh`

- [ ] **Step 1: 테스트 작성**

```bash
mkdir -p manifests

cat > tests/smoke/02-manifests.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# JSON 유효성
node -e "JSON.parse(require('fs').readFileSync('$ROOT/manifests/templates.json','utf8'))" \
  || { echo "FAIL: templates.json invalid JSON"; exit 1; }
node -e "JSON.parse(require('fs').readFileSync('$ROOT/manifests/skills.json','utf8'))" \
  || { echo "FAIL: skills.json invalid JSON"; exit 1; }

# templates.json 구조
node -e "
  const t = JSON.parse(require('fs').readFileSync('$ROOT/manifests/templates.json','utf8'));
  if (!t.fullstack) throw new Error('fullstack template missing');
  if (!Array.isArray(t.fullstack.files)) throw new Error('files must be array');
  if (!Array.isArray(t.fullstack.skills)) throw new Error('skills must be array');
  if (!t.fullstack.placeholders) throw new Error('placeholders missing');
  console.log('templates.json structure OK');
"

# skills.json 구조 + SKILL.md 존재 확인
node -e "
  const fs = require('fs');
  const path = require('path');
  const s = JSON.parse(fs.readFileSync('$ROOT/manifests/skills.json','utf8'));
  if (!s['coding-conventions']) throw new Error('coding-conventions missing');
  if (!s['coding-conventions'].path) throw new Error('path missing');
  const skillPath = path.join('$ROOT', s['coding-conventions'].path);
  const stat = fs.statSync(skillPath);
  if (!stat.isDirectory()) throw new Error('Skill path is not a directory');
  if (!fs.existsSync(path.join(skillPath, 'SKILL.md'))) throw new Error('SKILL.md missing in skill directory');
  console.log('skills.json structure OK');
"

# manifests에 선언된 파일이 실제 존재하는지 확인
node -e "
  const fs = require('fs');
  const path = require('path');
  const t = JSON.parse(fs.readFileSync('$ROOT/manifests/templates.json','utf8'));
  for (const entry of t.fullstack.files) {
    const src = entry.split(' -> ')[0].trim();
    const full = path.join('$ROOT', src);
    if (!fs.existsSync(full)) throw new Error('File not found: ' + src);
  }
  const s = JSON.parse(fs.readFileSync('$ROOT/manifests/skills.json','utf8'));
  for (const skill of t.fullstack.skills) {
    const skillPath = path.join('$ROOT', s[skill].path);
    if (!fs.existsSync(skillPath)) throw new Error('Skill dir not found: ' + skill);
  }
  console.log('manifest file references OK');
"

# package.json
node -e "
  const p = JSON.parse(require('fs').readFileSync('$ROOT/package.json','utf8'));
  if (!p.bin || !p.bin['agent-foundry']) throw new Error('bin.agent-foundry missing');
  if (p.dependencies && Object.keys(p.dependencies).length > 0) throw new Error('external dependencies not allowed');
  console.log('package.json OK');
"

echo "OK: manifests"
SCRIPT
chmod +x tests/smoke/02-manifests.sh
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
bash tests/smoke/02-manifests.sh
```
Expected: `FAIL: templates.json invalid JSON` 또는 파일 없음 에러

- [ ] **Step 3: manifests/templates.json 작성**

```bash
cat > manifests/templates.json << 'EOF'
{
  "fullstack": {
    "files": [
      "templates/CLAUDE.md.tmpl -> CLAUDE.md",
      "templates/mcp.json.tmpl -> .mcp.json",
      "templates/scripts/orchestrate.sh -> scripts/orchestrate.sh",
      "templates/scripts/ralph-loop.sh -> scripts/ralph-loop.sh",
      "templates/scripts/merge-worktree.sh -> scripts/merge-worktree.sh",
      "templates/handoff/goal.md -> docs/templates/goal.md",
      "templates/handoff/prd.md -> docs/templates/prd.md",
      "templates/handoff/screen-spec.md -> docs/templates/screen-spec.md",
      "templates/handoff/api-spec.md -> docs/templates/api-spec.md",
      "templates/handoff/architecture.md -> docs/templates/architecture.md",
      "checklists/kickoff.md -> docs/checklists/kickoff.md",
      "checklists/review-criteria.md -> docs/checklists/review-criteria.md",
      "adr/ADR-000-template.md -> docs/adr/ADR-000-template.md",
      "templates/NEXT_STEPS/fullstack.md -> NEXT_STEPS.md"
    ],
    "skills": ["coding-conventions"],
    "placeholders": {
      "PROJECT_NAME": "--name flag value",
      "GITHUB_REPO": "--repo flag value (empty string if not provided)"
    }
  }
}
EOF
```

- [ ] **Step 4: manifests/skills.json 작성**

```bash
cat > manifests/skills.json << 'EOF'
{
  "coding-conventions": {
    "path": "skills/coding-conventions",
    "description": "TS/React 명명규칙, FP 패턴, FSD 구조, Zustand/XState 패턴"
  }
}
EOF
```

- [ ] **Step 5: 테스트 통과 확인** (package.json 없으면 해당 부분은 일단 실패 — Task 6에서 해결)

```bash
bash tests/smoke/02-manifests.sh
```
Expected: `manifest file references OK` 이후 `package.json` 에러 — Task 6 이후 전체 통과

- [ ] **Step 6: 커밋**

```bash
git add manifests/ tests/smoke/02-manifests.sh
git commit -m "feat: 매니페스트 파일 작성"
```

---

## Task 6: package.json 작성

**Files:**
- Create: `package.json`

- [ ] **Step 1: package.json 작성**

```bash
cat > package.json << 'EOF'
{
  "name": "agent-foundry",
  "version": "0.1.0",
  "description": "Greenfield AI 운영 환경 부트스트랩 도구",
  "bin": {
    "agent-foundry": "./bin/agent-foundry.js"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "keywords": ["claude", "ai", "scaffold", "skills"],
  "license": "MIT"
}
EOF
```

- [ ] **Step 2: 테스트 통과 확인**

```bash
bash tests/smoke/02-manifests.sh
```
Expected: `OK: manifests`

- [ ] **Step 3: 커밋**

```bash
git add package.json
git commit -m "feat: package.json bin 엔트리 추가"
```

---

## Task 7: bin/agent-foundry.js 구현

**Files:**
- Create: `bin/agent-foundry.js`
- Create: `tests/smoke/03-cli.sh`

- [ ] **Step 1: 테스트 작성**

```bash
mkdir -p bin

cat > tests/smoke/03-cli.sh << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- Test 1: --template fullstack --name test-project ---"
node "$ROOT/bin/agent-foundry.js" \
  --template fullstack \
  --name test-project \
  --output "$TMP/test1"

for f in \
  "CLAUDE.md" \
  ".mcp.json" \
  "scripts/orchestrate.sh" \
  "scripts/ralph-loop.sh" \
  "scripts/merge-worktree.sh" \
  "docs/templates/goal.md" \
  "docs/checklists/kickoff.md" \
  "docs/adr/ADR-000-template.md" \
  "NEXT_STEPS.md" \
  "skills-lock.json" \
  ".agents/skills/coding-conventions/SKILL.md"; do
  [[ -f "$TMP/test1/$f" ]] || { echo "MISSING: $f"; exit 1; }
done

# placeholder 치환 확인: PROJECT_NAME이 실제 값으로 치환됐는지
grep -q "test-project" "$TMP/test1/CLAUDE.md" || { echo "FAIL: PROJECT_NAME not substituted in CLAUDE.md"; exit 1; }
# unreplaced placeholder가 없는지
! grep -q "{{PROJECT_NAME}}" "$TMP/test1/CLAUDE.md" || { echo "FAIL: unreplaced {{PROJECT_NAME}} in CLAUDE.md"; exit 1; }

# skills-lock.json 구조
node -e "
  const lock = JSON.parse(require('fs').readFileSync('$TMP/test1/skills-lock.json','utf8'));
  if (!lock.installedAt) throw new Error('installedAt missing');
  if (!lock.ref) throw new Error('ref missing');
  if (lock.template !== 'fullstack') throw new Error('template mismatch: ' + lock.template);
  if (!lock.skills.includes('coding-conventions')) throw new Error('coding-conventions missing from lock.skills');
  console.log('skills-lock.json OK');
"

echo "--- Test 2: --skills only ---"
node "$ROOT/bin/agent-foundry.js" \
  --skills coding-conventions \
  --name test-project \
  --output "$TMP/test2"

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
  if (lock.template !== null) throw new Error('template should be null in skills-only mode, got: ' + lock.template);
  if (!lock.skills.includes('coding-conventions')) throw new Error('skills missing from lock');
  console.log('Test 4 lock OK');
"

echo "OK: CLI"
SCRIPT
chmod +x tests/smoke/03-cli.sh
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
bash tests/smoke/03-cli.sh
```
Expected: `bin/agent-foundry.js` 없음으로 FAIL

- [ ] **Step 3: CLI 구현**

```bash
cat > bin/agent-foundry.js << 'EOF'
#!/usr/bin/env node
// bin/agent-foundry.js — agent-foundry CLI
// Node 18+ built-in only: fs, path, process
'use strict';

const fs = require('fs');
const path = require('path');

// ── 인자 파싱 ────────────────────────────────────────────────
const args = process.argv.slice(2);
const flags = {};
for (let i = 0; i < args.length; i++) {
  if (args[i].startsWith('--')) {
    flags[args[i].slice(2)] = args[i + 1] !== undefined ? args[i + 1] : '';
    i++;
  }
}

const template  = flags.template || null;
const skillsFlag = flags.skills ? flags.skills.split(',').map(s => s.trim()).filter(Boolean) : [];
const projectName = flags.name || path.basename(process.cwd());
const githubRepo  = flags.repo  || '';
const outputDir   = flags.output ? path.resolve(flags.output) : process.cwd();

if (!template && skillsFlag.length === 0) {
  console.error('Error: --template or --skills is required');
  process.exit(1);
}

// ── 경로 설정 ────────────────────────────────────────────────
const ROOT = path.join(__dirname, '..');
const manifestsDir = path.join(ROOT, 'manifests');

// ── 헬퍼 ────────────────────────────────────────────────────
function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function applyPlaceholders(content, placeholders) {
  let result = content;
  for (const [key, value] of Object.entries(placeholders)) {
    result = result.split(`{{${key}}}`).join(value);
  }
  return result;
}

function copyFile(src, dest, placeholders) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  const raw = fs.readFileSync(src, 'utf8');
  fs.writeFileSync(dest, applyPlaceholders(raw, placeholders), 'utf8');
}

function copyDir(src, dest, placeholders) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath, placeholders);
    } else {
      copyFile(srcPath, destPath, placeholders);
    }
  }
}

// ── 실행 ────────────────────────────────────────────────────
const placeholders  = { PROJECT_NAME: projectName, GITHUB_REPO: githubRepo };
const skillsManifest = readJson(path.join(manifestsDir, 'skills.json'));
let installedSkills  = [...skillsFlag];

if (template) {
  const templatesManifest = readJson(path.join(manifestsDir, 'templates.json'));
  const tmpl = templatesManifest[template];
  if (!tmpl) {
    console.error(`Error: unknown template "${template}"`);
    process.exit(1);
  }
  for (const entry of tmpl.files) {
    const [srcRel, destRel] = entry.split(' -> ').map(s => s.trim());
    copyFile(path.join(ROOT, srcRel), path.join(outputDir, destRel), placeholders);
  }
  for (const s of tmpl.skills) {
    if (!installedSkills.includes(s)) installedSkills.push(s);
  }
}

for (const skillName of installedSkills) {
  const skill = skillsManifest[skillName];
  if (!skill) {
    console.error(`Error: unknown skill "${skillName}"`);
    process.exit(1);
  }
  copyDir(
    path.join(ROOT, skill.path),
    path.join(outputDir, '.agents', 'skills', skillName),
    placeholders
  );
}

const lock = {
  installedAt: new Date().toISOString(),
  source: 'github:kyeongsoo-yoo/agent-foundry',
  ref: 'local',
  template: template || null,
  skills: installedSkills,
};
fs.writeFileSync(path.join(outputDir, 'skills-lock.json'), JSON.stringify(lock, null, 2), 'utf8');

console.log(`\n✓ agent-foundry init complete — ${projectName}`);
console.log(`  template : ${template || '(none)'}`);
console.log(`  skills   : ${installedSkills.join(', ')}`);
if (template) console.log(`\nNext: see NEXT_STEPS.md`);
EOF
```

**Note:** `skills-lock.json`의 `ref` 필드는 로컬 실행 시 `"local"`을 사용한다. `npx github:` 배포 환경에서는 다운로드된 레포의 HEAD SHA가 별도로 주입 가능하지만, 현재 MVP에서는 `"local"`이 허용된 값이다.

- [ ] **Step 4: 실행 권한 부여**

```bash
chmod +x bin/agent-foundry.js
```

- [ ] **Step 5: 테스트 통과 확인**

```bash
bash tests/smoke/03-cli.sh
```
Expected: `OK: CLI`

- [ ] **Step 6: 커밋**

```bash
git add bin/ tests/smoke/03-cli.sh
git commit -m "feat: CLI 구현 (bin/agent-foundry.js)"
```

---

## Task 8: 전체 스모크 + README 업데이트

**Files:**
- Create: `tests/smoke/run-all.sh`
- Modify: `README.md`

- [ ] **Step 1: run-all.sh 작성**

```bash
cat > tests/smoke/run-all.sh << 'SCRIPT'
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
SCRIPT
chmod +x tests/smoke/run-all.sh
```

- [ ] **Step 2: 전체 테스트 실행**

```bash
bash tests/smoke/run-all.sh
```
Expected: `ALL SMOKE TESTS PASSED`

- [ ] **Step 3: README.md "현재 상태" 섹션 업데이트**

README.md의 `## 현재 상태` 섹션을 찾아 아래로 교체:

```markdown
## 현재 상태 (2026-03-17)

- 완료:
  - 허브 아키텍처 설계 문서 작성
  - MVP 구현 계획 문서 작성
  - Greenfield AI Setup 설계 및 구현 계획 완료
- 구현 완료:
  - `coding-conventions` 스킬 (autonomous-dev-pipeline 포팅)
  - 풀스택 템플릿 파일 (CLAUDE.md, mcp.json, 파이프라인 스크립트, 핸드오프 템플릿)
  - `bin/agent-foundry.js` CLI
  - `manifests/templates.json`, `manifests/skills.json`
```

그리고 `## 사용 예시` 섹션에 `npx` 명령 추가:

~~~markdown
## 사용 예시

### npx (설치 불필요)

~~~bash
# 새 프로젝트 디렉토리에서
npx github:kyeongsoo-yoo/agent-foundry --template fullstack --name my-app
~~~

### 스킬만 별도 설치

~~~bash
npx skills add https://github.com/kyeongsoo-yoo/agent-foundry --skill coding-conventions
~~~
~~~

- [ ] **Step 4: 재실행으로 idempotent 확인**

```bash
bash tests/smoke/run-all.sh
```
Expected: `ALL SMOKE TESTS PASSED` (두 번 연속 실행해도 동일)

- [ ] **Step 5: 최종 커밋**

```bash
git add tests/smoke/run-all.sh README.md
git commit -m "feat: 전체 스모크 테스트 및 README 업데이트"
```

---

## 완료 기준

- `bash tests/smoke/run-all.sh` 전체 통과
- `node bin/agent-foundry.js --template fullstack --name test --output /tmp/verify` 실행 시:
  - `CLAUDE.md` — `test-project` 포함, `{{PROJECT_NAME}}` 미존재
  - `.mcp.json`, `scripts/` (3개), `docs/templates/` (5개), `docs/checklists/` (2개), `docs/adr/ADR-000-template.md`, `NEXT_STEPS.md`
  - `.agents/skills/coding-conventions/SKILL.md`
  - `skills-lock.json`
  모두 생성됨
