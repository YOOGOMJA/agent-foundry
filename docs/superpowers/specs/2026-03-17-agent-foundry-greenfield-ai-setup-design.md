# Design: agent-foundry — Greenfield AI Setup

> 작성일: 2026-03-17 | 상태: Approved

## 개요

`agent-foundry`는 그린필드 프로젝트를 시작할 때 AI 운영 환경(skills, CLAUDE.md, 파이프라인 스크립트)을 한 번에 세팅하는 컨텐츠 허브다.
새 프로젝트 디렉토리에서 `npx github:kyeongsoo-yoo/agent-foundry --template fullstack --name my-app` 한 줄로 부트스트랩을 완료한다.

---

## Part 1: 아키텍처

### 두 레이어 구조

```
agent-foundry/
│
│  ── 컨텐츠 레이어 ──────────────────────────────────
├── skills/
│   └── coding-conventions/
│       ├── SKILL.md
│       └── references/         # naming, fp, fsd, zustand, xstate
├── templates/
│   ├── CLAUDE.md.tmpl
│   ├── mcp.json.tmpl
│   ├── NEXT_STEPS/
│   │   └── fullstack.md        # 템플릿별 static 파일
│   ├── handoff/                # goal, prd, screen-spec, api-spec, architecture
│   └── scripts/
│       ├── orchestrate.sh
│       ├── ralph-loop.sh
│       └── merge-worktree.sh
├── checklists/
│   ├── kickoff.md
│   └── review-criteria.md
├── adr/
│   └── ADR-000-template.md
│
│  ── 전달 레이어 ──────────────────────────────────
├── bin/
│   └── agent-foundry.js        # ~100줄, Node built-in만 사용
├── manifests/
│   ├── templates.json          # 템플릿별 파일 목록 + placeholder 정의
│   └── skills.json             # 등록된 스킬 목록
└── package.json                # bin 엔트리
```

### 실행 흐름

```
npx github:kyeongsoo-yoo/agent-foundry --template fullstack --name my-app
  ↓
manifests/templates.json에서 fullstack 파일 목록 로드
  ↓
GitHub API로 각 파일 fetch
  ↓
현재 디렉토리에 write + {{PLACEHOLDER}} 치환
  ↓
skills-lock.json 생성 (설치 시점 commit SHA 기록)
  ↓
NEXT_STEPS.md 복사
  ↓
완료 출력
```

---

## Part 2: 컨텐츠

### 포팅 출처

`autonomous-dev-pipeline` 노트에서 다음을 포팅한다:

| 출처 | agent-foundry 경로 | 비고 |
|------|-------------------|------|
| `skills/coding-conventions/` | `skills/coding-conventions/` | 그대로 |
| `templates/CLAUDE.md.tmpl` | `templates/CLAUDE.md.tmpl` | |
| `templates/mcp.json.tmpl` | `templates/mcp.json.tmpl` | |
| `templates/scripts/` | `templates/scripts/` | bash 유지 |
| `templates/handoff/` | `templates/handoff/` | |
| `checklists/kickoff.md` | `checklists/kickoff.md` | |
| `checklists/review-criteria.md` | `checklists/review-criteria.md` | |
| ADR 7개 | **포팅 안 함** | 특정 프로젝트 결정 |
| `toolchain-catalog.md` | `docs/references/toolchain-catalog.md` | agent-foundry 레포 내부 참고 문서. 대상 프로젝트에 복사하지 않음 |

ADR 7개는 pipeline 설계 과정의 프로젝트 결정이므로 agent-foundry에 포함하지 않는다.
새 프로젝트의 ADR은 `adr/ADR-000-template.md`를 기반으로 프로젝트에서 직접 생성한다.

### domain-agnostic 원칙

현재 컨텐츠는 전부 **구조/프로세스 레벨**이라 도메인과 무관하다.
도메인 종속 스킬(ecommerce, fintech 등)이 생기면 그때 post-copy configuration을 도입한다. 지금은 불필요.

---

## Part 3: CLI 설계

### 역할

파일을 가져다 쓰는 배달부. AI 없음. Node built-in(`fs`, `fetch`, `path`)만 사용. 외부 의존성 없음.

### fetch 전략

- `raw.githubusercontent.com/{owner}/{repo}/{ref}/{path}` 엔드포인트 사용 (Contents API 불필요, rate limit 없음)
- 환경변수 `GITHUB_TOKEN`이 있으면 `Authorization: Bearer` 헤더로 전달 (private repo 지원)
- 파일 fetch 실패 시(네트워크 오류, 404 등) 즉시 abort, non-zero exit code, 실패한 경로 출력

### placeholder 형식

템플릿 파일 내 `{{KEY}}` 형식을 문자열 치환한다. 예: `{{PROJECT_NAME}}` → `my-app`.

### 플래그 정의

| 플래그 | 필수 | 설명 |
|--------|------|------|
| `--template` | 하나 이상 필수 (동시 사용 가능) | 템플릿 이름 (예: `fullstack`) |
| `--skills` | 하나 이상 필수 (동시 사용 가능) | 스킬 이름 콤마 구분 (예: `coding-conventions`) |
| `--name` | 선택 | 프로젝트 이름. 없으면 현재 디렉토리 이름 사용 |
| `--repo` | 선택 | GitHub repo 주소. 없으면 빈칸 |
| `--output` | 선택 (테스트/CI용) | 출력 디렉토리 override. 없으면 `process.cwd()` |

### 플래그 조합 규칙

| 명령 | 동작 |
|------|------|
| `--template fullstack` | manifests에 정의된 files + skills 전부 |
| `--skills coding-conventions` | 스킬만, 템플릿 파일 없이 |
| `--template fullstack --skills foo` | fullstack 전부 + foo 추가 |
| 플래그 없음 | 에러 출력 후 종료 |

### manifests/templates.json 구조

```json
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
      "PROJECT_NAME": "--name 플래그값",
      "GITHUB_REPO": "--repo 플래그값 (없으면 빈칸)"
    }
  }
}
```

### manifests/skills.json 구조

스킬은 대상 프로젝트의 `.agents/skills/<name>/`에 복사된다.

```json
{
  "coding-conventions": {
    "path": "skills/coding-conventions",
    "description": "TS/React 명명규칙, FP 패턴, FSD 구조, Zustand/XState 패턴"
  }
}
```

### skills-lock.json (출력물)

버전 태그 기반 lock(이전 MVP 설계)을 SHA 기반으로 변경한다. `update-skills.sh`는 이 설계 범위 밖이다.

```json
{
  "installedAt": "2026-03-17T00:00:00Z",
  "source": "github:kyeongsoo-yoo/agent-foundry",
  "ref": "abc1234",
  "template": "fullstack",
  "skills": ["coding-conventions"]
}
```

---

## Part 4: NEXT_STEPS.md

init 완료 직후 프로젝트 루트에 생성되는 가이드. copy-pasteable 명령 위주.

```markdown
# Next Steps

## 1. 플러그인 & 스킬 설치
\```bash
claude plugin marketplace add phuryn/pm-skills
claude plugin marketplace add zircote/adr
npx skills add feature-sliced/skills
npx skills add https://github.com/wshobson/agents --skill tailwind-design-system
npx skills add https://github.com/anthropics/skills --skill webapp-testing
\```

## 2. 환경 설정
- [ ] `.mcp.json`에 `GITHUB_TOKEN` 입력
- [ ] `ANTHROPIC_API_KEY` 환경변수 설정 (`export ANTHROPIC_API_KEY=...`)
- [ ] `gh auth status` 확인

## 3. 실행 권한 부여
\```bash
chmod +x scripts/orchestrate.sh scripts/ralph-loop.sh scripts/merge-worktree.sh
\```

## 4. 목표 작성 후 파이프라인 시작
\```bash
# docs/templates/goal.md 참고해서 docs/goal.md 작성
./scripts/orchestrate.sh
\```
```

템플릿별 static 파일(`templates/NEXT_STEPS/fullstack.md`)로 관리. generated 방식은 YAGNI.

---

## Part 5: ADR 거버넌스

예시 ADR 7개는 포함하지 않지만 운영 체계는 세 곳에 존재한다:

1. **CLAUDE.md** — 에이전트가 따르는 ADR 규칙 (자동 승인 / 인간 승인 기준 명시)
2. **`zircote/adr` 플러그인** — ADR 생성 도구 (NEXT_STEPS.md에서 설치 안내)
3. **`docs/adr/ADR-000-template.md`** — 빈 포맷 템플릿

---

## Part 6: 배포 & 버전 관리

### 배포 방식

```bash
# 프로젝트 부트스트랩
npx github:kyeongsoo-yoo/agent-foundry --template fullstack --name my-app

# 스킬만 별도 설치 (나중에 추가)
npx skills add https://github.com/kyeongsoo-yoo/agent-foundry --skill coding-conventions
```

npm publish 없음. GitHub 직접 참조. `npx github:user/repo`는 항상 최신을 가져오고, `skills-lock.json`이 설치 시점 SHA를 기록한다.

### 버전 업데이트 (미래)

현재 설계에 포함하지 않음. `update-skills.sh` 스크립트는 추후 구현.

---

## 결정 요약

| 결정 | 선택 | 근거 |
|------|------|------|
| 배포 방식 | `npx github:` direct | npm publish 오버헤드 불필요 |
| init에 AI | 없음 | 기계적 파일 복사, AI 불필요 |
| 스크립트 포맷 | bash + `claude -p` | 사용자가 수정하는 템플릿, 진입장벽 낮음 |
| post-copy config | 없음 | domain-agnostic 컨텐츠라 불필요 |
| marketplace.json | 없음 | GitHub URL로 `npx skills add` 직접 동작 |
| ADR 예시 | 포팅 안 함 | 프로젝트 특정 결정, agent-foundry 결정 아님 |
| NEXT_STEPS.md | static per template | YAGNI, 지금 템플릿 하나 |
