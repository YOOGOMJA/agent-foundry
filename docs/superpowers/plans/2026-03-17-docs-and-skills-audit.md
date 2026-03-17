# agent-foundry 문서 및 스킬 감사 구현 계획

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** agent-foundry 레포 자체에 필요한 운영 문서 3개, ADR 2개, 스킬 2개를 작성하여 AI 에이전트가 이 레포를 올바르게 사용할 수 있게 한다.

**Architecture:** 7개 항목은 서로 의존성 없음. 3개 그룹(문서, ADR, 스킬)으로 묶어 병렬 실행 가능. 모두 마크다운 파일 작성 작업이며 코드 변경 없음.

**Tech Stack:** Markdown, 기존 ADR 포맷(`docs/adr/`), 스킬 frontmatter 포맷

**Spec:** `docs/superpowers/specs/2026-03-17-agent-foundry-docs-and-skills-audit-design.md`

---

## 파일 맵

| 태스크 | 파일 경로 | 작업 |
|--------|---------|------|
| Task 1 | `CLAUDE.md` | 신규 생성 |
| Task 2 | `AGENTS.md` | 확장 (6줄 → 완성) |
| Task 3 | `CONTRIBUTION.md` | 확장 (3줄 → 완성) |
| Task 4 | `docs/adr/0003-cli-design-principles.md` | 신규 생성 |
| Task 5 | `docs/adr/0004-sha-based-lock.md` | 신규 생성 |
| Task 6 | `skills/skill-creator/SKILL.md` | 신규 생성 |
| Task 7 | `skills/vercel-react-best-practices/SKILL.md` | thin adapter로 교체 |

---

## Task 1: CLAUDE.md 작성

**Files:**
- Create: `CLAUDE.md`

**배경:** `templates/CLAUDE.md.tmpl`은 다른 프로젝트용. agent-foundry 레포 자체에는 Claude Code 운영 규칙이 없다.

- [ ] **Step 1: CLAUDE.md 작성**

아래 내용으로 `CLAUDE.md` 생성 (외부 펜스 4개 backtick — 내부 코드블록과 충돌 방지):

````markdown
# CLAUDE.md — agent-foundry

## 프로젝트 개요
- 도메인 독립 AI 스킬과 에이전트 운영 규칙을 모아두는 공개형 허브 저장소
- Node.js CLI(`bin/agent-foundry.js`)로 새 프로젝트에 스킬/템플릿 배포
- 외부 의존성 없음 (Node built-in만 사용)

## 핵심 원칙
- YAGNI: 현재 요구사항에 없는 기능·추상화 금지
- 단순함 우선: CLI는 순수 파일 배달부. AI/LLM 없음
- 한국어 문서화: 운영 문서와 가이드는 한국어 기준

## 스킬 작성/수정 규칙
- 새 스킬 생성·수정 시 `skills/skill-creator/SKILL.md`를 먼저 로드할 것
- 스킬 추가 완료 조건: SKILL.md 작성 -> `manifests/skills.json` 등록 -> smoke test 통과
- `skill-creator` 자체는 manifests에 등록하지 않음 (배포용 스킬 아님)

## 파일 레이아웃 핵심

```
skills/          # 배포 가능한 스킬 (manifests/skills.json에 등록)
templates/       # 대상 프로젝트에 복사되는 파일 (직접 수정 금지 원칙)
manifests/       # skills.json, templates.json
bin/             # agent-foundry.js CLI
docs/adr/        # 이 레포의 아키텍처 결정 기록
docs/plans/      # 구현 계획
docs/references/ # 참고 문서 (toolchain-catalog 등)
adr/             # ADR-000-template.md (대상 프로젝트에 복사됨, docs/adr/ 와 다름)
checklists/      # 대상 프로젝트 시작 시 사용하는 체크리스트
```

## ADR 규칙
- 신규 아키텍처/배포 결정 시 `docs/adr/` 에 ADR 작성
- 파일명: `NNNN-<topic>.md`
- 자동 진행 가능: 단일 파일 수정, 기존 ADR 세부 조정
- 승인 필요: 신규 스킬 추가, CLI 플래그 변경, manifests 구조 변경

## Claude Code 전용 설정
- 허용 도구: Read, Edit, Write, Bash(테스트 실행만), Glob, Grep
- 자동 승인: smoke test 실행(`bash tests/smoke/run-all.sh`), 마크다운 파일 작성
- 인간 승인 필요: `manifests/*.json` 구조 변경, `bin/agent-foundry.js` 수정
- 세션 비용 목표: 마크다운 작성 태스크는 `--max-turns 20` 이내

## 테스트 실행

```bash
bash tests/smoke/run-all.sh
```

## 커밋 컨벤션
feat / fix / docs / chore — conventional commits 형식
````

- [ ] **Step 2: 검증**

다음을 확인:
- `CLAUDE.md` 파일이 레포 루트에 존재하는가
- 7개 섹션(프로젝트 개요, 핵심 원칙, 스킬 규칙, 파일 레이아웃, ADR 규칙, Claude Code 설정, 테스트)이 모두 포함되었는가
- `templates/CLAUDE.md.tmpl`과 내용이 다른가 (이 파일은 agent-foundry용, 템플릿은 다른 프로젝트용)
- `docs/adr/`와 루트 `adr/`의 구분이 명시되었는가

- [ ] **Step 3: 커밋**

```bash
git add CLAUDE.md
git commit -m "docs: agent-foundry 레포 자체 CLAUDE.md 추가"
```

---

## Task 2: AGENTS.md 확장

**Files:**
- Modify: `AGENTS.md` (현재 6줄)

**배경:** 현재 내용은 "목적: 도메인 독립 스킬 허브 운영"과 "skill-creator 우선 사용" 2줄뿐. 에이전트가 실제로 동작하기 위한 정보가 없다.

- [ ] **Step 1: AGENTS.md 전체 교체**

````markdown
# Agent Foundry 운영 규칙

## 목적
도메인 독립 스킬 허브 운영. 새 프로젝트 부트스트랩 시 필요한 스킬과 템플릿을 제공한다.

## 파일 레이아웃

```
skills/          # 배포 가능한 스킬. 각 스킬은 skills/<name>/SKILL.md
templates/       # 대상 프로젝트에 복사되는 파일 (이 레포 운영용이 아님)
manifests/       # skills.json (스킬 인덱스), templates.json (템플릿 인덱스)
bin/             # agent-foundry.js — Node built-in만 사용하는 CLI
docs/adr/        # 아키텍처 결정 기록
docs/plans/      # 구현 계획
docs/references/ # 참고 문서 (toolchain-catalog 등)
checklists/      # 대상 프로젝트 시작 시 사용하는 체크리스트
adr/             # ADR-000-template.md (대상 프로젝트에 복사됨)
tests/smoke/     # smoke test
```

## 스킬 작성 규칙
1. 새 스킬 생성·수정 전에 `skills/skill-creator/SKILL.md`를 먼저 읽는다
2. 모든 스킬은 `skills/<name>/SKILL.md` + frontmatter(`name`, `description`) 포함
3. 배포용 스킬은 반드시 `manifests/skills.json`에 등록
4. 등록 후 smoke test 통과 필수: `bash tests/smoke/run-all.sh`

## templates/ 수정 원칙
- `templates/` 하위 파일은 대상 프로젝트에 복사되는 컨텐츠
- agent-foundry 레포 운영 규칙을 여기에 쓰지 않는다
- `templates/CLAUDE.md.tmpl`은 다른 프로젝트용이며 이 레포 규칙과 무관

## 금지 사항
- CLI(`bin/agent-foundry.js`)에 LLM 호출 추가 금지
- `manifests/skills.json`에 등록 없이 스킬 디렉토리만 생성 금지
- smoke test 통과 전 PR 생성 금지

## 테스트

```bash
bash tests/smoke/run-all.sh
```
````

- [ ] **Step 2: 검증**

- 파일 레이아웃, 스킬 작성 규칙, 금지 사항 섹션이 모두 있는가
- "skill-creator" 문자열이 포함되었는가 (smoke test `01-required-docs.sh`가 이를 grep함)

- [ ] **Step 3: 커밋**

```bash
git add AGENTS.md
git commit -m "docs: AGENTS.md 운영 규칙 상세화"
```

---

## Task 3: CONTRIBUTION.md 확장

**Files:**
- Modify: `CONTRIBUTION.md` (현재 3줄)

**배경:** 현재 "기본 흐름: Issue -> Plan -> Branch/Worktree -> Commit -> PR" 한 줄뿐.

**주의:** smoke test `tests/smoke/docs/01-required-docs.sh`가 CONTRIBUTION.md에서 `"Issue -> Plan -> Branch/Worktree -> Commit -> PR"` (ASCII `->`)를 grep한다. 아래 내용에서 반드시 ASCII `->` 사용할 것. Unicode `→` 사용 시 smoke test 실패.

- [ ] **Step 1: CONTRIBUTION.md 전체 교체**

````markdown
# 기여 가이드

## 기본 흐름

```
Issue -> Plan -> Branch/Worktree -> Commit -> PR
```

## 브랜치 네이밍

```
feat/<topic>      # 새 기능 (스킬 추가, CLI 기능 등)
fix/<topic>       # 버그 수정
docs/<topic>      # 문서만 변경
chore/<topic>     # 빌드, 설정, 정리
```

예시: `feat/skill-creator`, `docs/agents-md-update`

## 커밋 컨벤션

conventional commits 형식:

```
feat: skill-creator 스킬 추가
fix: bootstrap-project.sh 경로 오류 수정
docs: AGENTS.md 운영 규칙 상세화
chore: manifests/skills.json coding-conventions 등록
```

## 스킬 기여 프로세스

새 스킬을 추가할 때:

1. `skills/skill-creator/SKILL.md` 읽기
2. `skills/<skill-name>/SKILL.md` 작성 (frontmatter 필수)
3. `manifests/skills.json`에 등록
4. smoke test 통과 확인: `bash tests/smoke/run-all.sh`
5. PR 생성 (smoke test 통과 증거 포함)

## PR 요건

- [ ] smoke test 전체 통과: `bash tests/smoke/run-all.sh`
- [ ] 새 스킬이라면 `manifests/skills.json` 등록 포함
- [ ] 아키텍처 변경이라면 ADR 포함 (`docs/adr/NNNN-<topic>.md`)
- [ ] PR 본문에 변경 내용 요약 포함

## ADR 작성 기준

다음 경우 ADR 작성:
- 새 스킬 배포 방식 변경
- CLI 플래그 추가/변경
- manifests 구조 변경
- 외부 의존성 추가

자동 진행 가능 (ADR 불필요):
- 스킬 내용 수정
- 문서 업데이트
- 단일 파일 버그 수정
````

- [ ] **Step 2: 검증**

- 브랜치 네이밍, 커밋 컨벤션, 스킬 기여 프로세스, PR 요건, ADR 기준 섹션이 포함되었는가
- 기본 흐름에 ASCII `->` (Unicode `→` 아님)가 사용되었는가

- [ ] **Step 3: smoke test 실행**

```bash
bash tests/smoke/run-all.sh
```

Expected: 전체 통과. `01-required-docs.sh`가 `"Issue -> Plan"` grep에 성공해야 함.

- [ ] **Step 4: 커밋**

```bash
git add CONTRIBUTION.md
git commit -m "docs: CONTRIBUTION.md 기여 가이드 상세화"
```

---

## Task 4: ADR-0003 CLI 설계 원칙

**Files:**
- Create: `docs/adr/0003-cli-design-principles.md`

**배경:** greenfield AI setup 스펙에 결정 요약이 있지만 공식 ADR이 없다. 기존 ADR 포맷(`docs/adr/0001-skills-hub-distribution.md`) 참고.

- [ ] **Step 1: ADR-0003 작성**

```markdown
# ADR-0003: CLI 설계 원칙

- 상태: Accepted
- 날짜: 2026-03-17
- 관련: docs/superpowers/specs/2026-03-17-agent-foundry-greenfield-ai-setup-design.md

## 문맥

agent-foundry CLI(`bin/agent-foundry.js`)의 배포 방식과 AI 사용 여부를 결정해야 했다.
새 프로젝트 부트스트랩 시 GitHub에서 파일을 가져와 대상 디렉토리에 복사하는 단순한 작업이다.

## 결정

**1. npm publish 없이 `npx github:kyeongsoo-yoo/agent-foundry` 직접 참조**

npm registry에 배포하지 않고 GitHub 레포를 직접 참조한다.

**2. CLI에 AI/LLM 없음 — 순수 파일 배달부**

CLI는 `fs`, `fetch`, `path` Node built-in만 사용한다. LLM API 호출 없음.
파일을 가져다 쓰는 기계적 복사 작업에 AI는 불필요하다.

## 근거

**npm publish 없이 GitHub 직접 참조:**
- npm 배포 프로세스(버전 태깅, 패키지 관리) 오버헤드 불필요
- `npx github:user/repo`는 항상 최신 main을 가져옴
- `skills-lock.json`이 설치 시점 SHA를 기록하므로 재현성은 별도 보장됨
- private repo 지원 시 `GITHUB_TOKEN`만 있으면 됨 (npm token 불필요)

**AI 없음:**
- 투명성: 복사 작업의 결과가 예측 가능해야 함
- 비용: LLM 호출 없이 무료로 동작
- 유지보수: 외부 의존성(anthropic SDK 등) 없음
- 신뢰성: 네트워크 오류 외에 실패 원인이 없음

## 결과

- `bin/agent-foundry.js` — ~100줄, Node built-in만 사용
- `raw.githubusercontent.com` 엔드포인트로 파일 fetch (rate limit 없음)
- 파일 fetch 실패 시 즉시 abort, non-zero exit code
```

- [ ] **Step 2: 검증**

- 기존 ADR 포맷(상태, 날짜, 문맥, 결정, 근거, 결과)을 따르는가
- 두 결정(npx github:, AI 없음)이 모두 포함되었는가

- [ ] **Step 3: 커밋**

```bash
git add docs/adr/0003-cli-design-principles.md
git commit -m "docs: ADR-0003 CLI 설계 원칙 (npx github, AI 없음) 추가"
```

---

## Task 5: ADR-0004 SHA 기반 lock 정책

**Files:**
- Create: `docs/adr/0004-sha-based-lock.md`

**배경:** ADR-0002는 lock 파일 메커니즘(수동 업데이트 정책)을 다루고, ADR-0004는 참조 타입(SHA vs 태그)을 다룬다. 구분된 결정.

- [ ] **Step 1: ADR-0004 작성**

````markdown
# ADR-0004: SHA 기반 lock 정책

- 상태: Accepted
- 날짜: 2026-03-17
- 관련: docs/adr/0002-version-lock-policy.md, docs/superpowers/specs/2026-03-17-agent-foundry-greenfield-ai-setup-design.md

## 문맥

스킬 설치 시점의 재현성을 보장하기 위해 `skills-lock.json`에 어떤 참조값을 기록할지 결정해야 했다.
ADR-0002에서 lock 파일을 사용하는 정책(수동 업데이트)을 결정했고,
이 ADR은 그 lock 파일의 참조 타입(semver 태그 vs commit SHA)을 결정한다.

## 결정

**semver 태그 대신 commit SHA를 `skills-lock.json`의 `ref` 필드에 기록한다.**

```json
{
  "installedAt": "2026-03-17T00:00:00Z",
  "source": "github:kyeongsoo-yoo/agent-foundry",
  "ref": "abc1234def5678",
  "template": "fullstack",
  "skills": ["coding-conventions"]
}
```

## 근거

**SHA의 불변성:**
- Git 태그는 `git push --force`로 다른 커밋을 가리키도록 변경 가능
- commit SHA는 내용 기반 해시로 변경 불가능
- lock 파일의 목적(재현성)에 SHA가 더 적합

**단순성:**
- semver 태그 관리(태깅 규율, CHANGELOG 유지)가 불필요
- SHA는 `git rev-parse HEAD`로 자동 획득 가능

## 결과

- `skills-lock.json`의 `ref` 필드는 항상 full commit SHA
- `bin/agent-foundry.js`는 설치 시 현재 HEAD SHA를 `ref`에 기록
- `update-skills.sh` 실행 시 새 SHA로 `ref` 업데이트

## ADR-0002와의 관계

ADR-0002: 설치 후 자동 업데이트 없음, 수동 `update-skills.sh`로만 업데이트
ADR-0004: 그 lock 파일에 기록하는 참조 타입은 commit SHA
````

- [ ] **Step 2: 검증**

- ADR-0002와의 관계가 명시되었는가
- SHA vs 태그 선택 근거가 포함되었는가

- [ ] **Step 3: 커밋**

```bash
git add docs/adr/0004-sha-based-lock.md
git commit -m "docs: ADR-0004 SHA 기반 lock 정책 추가"
```

---

## Task 6: skill-creator 스킬 작성

**Files:**
- Create: `skills/skill-creator/SKILL.md`

**배경:** README.md와 AGENTS.md에서 "스킬 작성/수정 시 skill-creator 우선 사용"이라고 명시하지만 실제로 없다.
이 스킬은 `manifests/skills.json`에 등록하지 않음 (배포용 스킬이 아니라 기여자용 메타 가이드).

- [ ] **Step 1: skill-creator SKILL.md 작성**

````markdown
---
name: skill-creator
description: agent-foundry에 새 스킬을 추가하거나 기존 스킬을 수정할 때 사용. 스킬 디렉토리 구조, frontmatter 형식, references/ 분리 기준, manifests 등록 절차를 안내.
---

# Skill Creator

agent-foundry에 새 스킬을 추가하거나 기존 스킬을 수정할 때 이 스킬을 먼저 로드한다.

> **이 스킬은 배포용 스킬이 아닙니다.** agent-foundry 레포 기여자(사람 또는 AI)가 스킬 작성 시 참조하는 메타 가이드입니다. `manifests/skills.json`에 등록하지 않습니다.

---

## 스킬 디렉토리 구조

```
skills/<skill-name>/
  SKILL.md          # 필수. 스킬 본문 + frontmatter
  references/       # 선택. 상세 참고 문서 (SKILL.md가 길어질 때 분리)
  scripts/          # 선택. 스킬이 참조하는 스크립트
  assets/           # 선택. 이미지, 예시 파일 등
```

---

## frontmatter 형식

모든 SKILL.md는 YAML frontmatter로 시작해야 한다:

```yaml
---
name: <skill-name>         # 필수. manifests/skills.json의 키와 일치
description: <한 줄 설명>   # 필수. 언제 이 스킬을 사용하는지 명확하게
---
```

**description 작성 원칙:**
- "언제 이 스킬이 활성화되는가"를 포함할 것
- 예시: `TypeScript/React 프로젝트의 코드를 작성, 수정, 리뷰할 때 자동 적용`
- 단순한 기능 나열보다 트리거 조건을 명확히

---

## SKILL.md 작성 원칙

1. **트리거 조건 명시**: 어떤 상황에서 이 스킬이 로드/적용되는가
2. **규칙 목록**: AI가 따라야 할 구체적인 규칙. 모호한 표현 금지
3. **예시 포함**: Good/Bad 예시가 있으면 훨씬 효과적
4. **YAGNI**: 지금 필요한 규칙만. 미래 확장성을 위한 규칙 금지
5. **길이 기준**: 500자 초과 상세 내용은 `references/`로 분리

---

## references/ 분리 기준

SKILL.md 본문이 길어지면 `references/`로 분리:

- **분리해야 할 것**: 패턴 예시, 상세 코드 스니펫, 도구별 설정 예시
- **본문에 유지할 것**: 핵심 규칙, 트리거 조건, references 링크

링크 형식:
```markdown
상세 패턴: [references/naming.md](references/naming.md)
```

---

## 완료 체크리스트

새 스킬 추가 시 아래를 순서대로 완료해야 한다:

- [ ] `skills/<skill-name>/SKILL.md` 작성 (frontmatter 포함)
- [ ] `manifests/skills.json`에 등록:
  ```json
  "<skill-name>": {
    "path": "skills/<skill-name>",
    "description": "<한 줄 설명>"
  }
  ```
- [ ] smoke test 통과: `bash tests/smoke/run-all.sh`
- [ ] 커밋 및 PR 생성

---

## 예시: 최소 스킬 구조

디렉토리:
```
skills/my-skill/
  SKILL.md
```

SKILL.md 내용:
```yaml
---
name: my-skill
description: React 컴포넌트를 작성할 때 적용. 접근성 규칙과 성능 패턴을 강제.
---
```

```markdown
# My Skill

## 적용 조건
React 컴포넌트(.tsx)를 작성하거나 수정할 때.

## 규칙
1. 모든 이미지에 alt 텍스트 필수
2. 이벤트 핸들러는 `handle` 접두사 사용
```

manifests/skills.json 등록:
```json
{
  "my-skill": {
    "path": "skills/my-skill",
    "description": "React 컴포넌트 접근성 및 성능 패턴"
  }
}
```
````

- [ ] **Step 2: 검증**

- frontmatter(`name`, `description`)가 포함되었는가
- 디렉토리 구조, frontmatter 형식, references/ 기준, 완료 체크리스트 4개 섹션이 있는가
- "manifests에 등록하지 않음" 안내가 본문 상단에 명확히 있는가

- [ ] **Step 3: smoke test 실행**

```bash
bash tests/smoke/run-all.sh
```

Expected: 전체 통과. skill-creator는 manifests에 등록하지 않으므로 manifest shape test에 영향 없음.

- [ ] **Step 4: 커밋**

```bash
git add skills/skill-creator/SKILL.md
git commit -m "feat: skill-creator 메타 스킬 추가"
```

---

## Task 7: vercel-react-best-practices thin adapter

**Files:**
- Modify: `skills/vercel-react-best-practices/SKILL.md` (현재 3줄 빈 껍데기)

**배경:** 외부에 `vercel-labs/agent-skills`의 `react-best-practices` 스킬이 있음 (23k stars, 확인됨). 이중 관리를 피하고 thin adapter로 교체.

**주의:** `manifests/skills.json`에 현재 `vercel-react-best-practices`가 등록되어 있지 않다. smoke test는 manifest 구조(path, description 필드 존재)만 확인하므로, 이 태스크 완료 후 smoke test는 통과하지만 manifest 등록 여부는 별도로 확인해야 한다. 등록이 필요한 경우 manifests/skills.json에 추가할 것.

- [ ] **Step 1: 외부 스킬 슬러그 확인**

`https://github.com/vercel-labs/agent-skills/tree/main/skills` 또는 레포 루트를 방문하여 `react-best-practices` 디렉토리/슬러그가 실제로 존재하는지 확인한다. (spec 작성 시점에 레포 존재는 확인됨, 슬러그는 write 시점에 재확인 필요)

- [ ] **Step 2: thin adapter로 교체**

````markdown
---
name: vercel-react-best-practices
description: React/Next.js 성능 최적화 패턴 적용 시 참조. Server/Client Component 분리, RSC data fetching, 번들 최적화 등을 다룬다.
---

# Vercel React Best Practices

> **이 스킬은 외부 스킬의 thin adapter입니다.** 상세 가이드는 아래 외부 스킬을 설치해 사용하세요.

## 외부 스킬 설치

```bash
npx skills add https://github.com/vercel-labs/agent-skills --skill react-best-practices
```

## 핵심 원칙 요약

1. **Server/Client Component 분리**: 데이터 페칭과 상태관리 로직은 Server Component에서. 인터랙션은 `'use client'`로 분리.
2. **RSC data fetching**: `fetch`에 `cache`, `next.revalidate` 옵션 활용. `unstable_cache`로 데이터 레이어 캐싱.
3. **번들 최적화**: `dynamic import`로 클라이언트 번들 분할. `next/image`, `next/font`로 정적 에셋 최적화.
4. **Route Handler 캐싱**: API Route는 `export const dynamic = 'force-dynamic'` 또는 기본 캐시 동작 명시.

자세한 패턴, 예시, 안티패턴은 외부 스킬 설치 후 참고.
````

- [ ] **Step 3: 검증**

- frontmatter(`name`, `description`)가 포함되었는가
- Step 1에서 확인한 외부 스킬 설치 명령이 올바른가
- 핵심 원칙 요약 4개가 있는가
- "thin adapter" 안내가 상단에 있는가

- [ ] **Step 4: smoke test 실행**

```bash
bash tests/smoke/run-all.sh
```

smoke test는 manifest에 등록된 스킬의 구조(path, description)를 확인한다. `vercel-react-best-practices`가 manifests/skills.json에 없으면 이 테스트와 무관하게 통과한다.

- [ ] **Step 5: 커밋**

```bash
git add skills/vercel-react-best-practices/SKILL.md
git commit -m "feat: vercel-react-best-practices thin adapter로 교체"
```

---

## 병렬 실행 그룹

7개 태스크는 서로 의존성 없음. 아래 3개 그룹을 동시 실행 가능:

```
그룹 A (Task 1, 2, 3)     그룹 B (Task 4, 5)     그룹 C (Task 6, 7)
├── Task 1: CLAUDE.md      ├── Task 4: ADR-0003    ├── Task 6: skill-creator
├── Task 2: AGENTS.md      └── Task 5: ADR-0004    └── Task 7: vercel-react (thin)
└── Task 3: CONTRIBUTION.md
```

그룹 내 태스크도 독립적이므로 7개 전체를 동시 실행해도 무방.
