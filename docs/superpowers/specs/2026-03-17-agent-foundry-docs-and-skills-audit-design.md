# Design: agent-foundry 문서 및 스킬 감사 & 보완

> 작성일: 2026-03-17 | 상태: Approved

## 개요

agent-foundry 레포 자체의 문서와 스킬 현황을 감사하고 누락된 항목을 보완한다.
대상 프로젝트에 배포되는 컨텐츠(templates/, checklists/)가 아니라,
**agent-foundry를 개발/운영할 때 필요한 문서와 스킬**이 대상이다.

---

## Part 1: 현황 및 갭 분석

### 프로젝트 운영 문서 현황

| 파일 | 현재 상태 | 판정 |
|------|---------|------|
| `README.md` | 충분히 작성됨 | 유지 |
| `AGENTS.md` | 6줄 — 사실상 비어있음 | 확장 필요 |
| `CONTRIBUTION.md` | 3줄 — 사실상 비어있음 | 확장 필요 |
| `CLAUDE.md` | 존재하지 않음 | 신규 작성 필요 |
| `docs/adr/0001, 0002` | 작성됨 | 유지 |
| `docs/references/toolchain-catalog.md` | 상세히 작성됨 | 유지 |

### ADR 갭

greenfield AI setup 스펙에 결정 요약이 있지만 공식 ADR이 없는 결정들:

| 결정 | 현재 위치 | 판정 |
|------|---------|------|
| npx github: 직접 배포 + CLI에 AI 없음 | specs/ 파일 내 결정 요약 | ADR-0003 작성 필요 |
| SHA 기반 lock | specs/ 파일 내 결정 요약 | ADR-0004 작성 필요 |

### 스킬 현황

| 스킬 | 현재 상태 | 판정 |
|------|---------|------|
| `skills/coding-conventions/` | 상세히 작성됨 | 유지 |
| `skills/vercel-react-best-practices/` | 3줄 빈 껍데기, manifests에 등록됨 | thin adapter로 교체 |
| `skills/skill-creator/` | 존재하지 않음 | 신규 작성 필요 |

---

## Part 2: 작성 항목 설계

### 그룹 A — 프로젝트 운영 문서 (병렬 가능)

#### CLAUDE.md (신규)

agent-foundry 레포에서 Claude Code가 따를 규칙. `templates/CLAUDE.md.tmpl`은 다른 프로젝트용이며 이것과 무관.

내용:
- 프로젝트 개요 (스킬 허브, Node CLI)
- 스킬 추가/수정 절차 (skill-creator 의무 사용)
- 테스트 실행 (`bash tests/smoke/run-all.sh`)
- 커밋 컨벤션 (기존 git log 기준: feat/docs/fix/chore)
- ADR 규칙 (신규 결정 시 ADR 작성)
- YAGNI 원칙 강제

#### AGENTS.md (확장)

에이전트-독립적 운영 원칙. Claude/Gemini/Codex 모두에 적용.

내용:
- 목적 요약 (도메인 독립 스킬 허브)
- 파일 레이아웃 요약 (skills/, templates/, manifests/, bin/)
- 스킬 작성 규칙 (skill-creator 의무 사용, 등록 절차)
- smoke test 실행 방법
- 변경 금지 사항 (templates/ 하위는 대상 프로젝트용, 직접 수정 금지 원칙)

**CLAUDE.md vs AGENTS.md 경계:**
- CLAUDE.md = Claude Code 전용: 세션 비용 제한, hook 설정, 권한 규칙
- AGENTS.md = 에이전트 독립: 운영 원칙, 파일 레이아웃, 스킬 등록 절차

#### CONTRIBUTION.md (확장)

외부 기여자 및 AI 에이전트가 참고하는 기여 가이드.

내용:
- 기본 흐름: Issue → Plan → Branch/Worktree → Commit → PR
- 브랜치 네이밍: `feat/<topic>`, `fix/<topic>`, `docs/<topic>`
- 커밋 컨벤션: conventional commits (feat/docs/fix/chore)
- 스킬 기여 프로세스 (skill-creator 사용 → manifest 등록 → smoke test 통과)
- PR 요건 (smoke test 통과 필수)

---

### 그룹 B — ADR 2개 (병렬 가능)

#### ADR-0003: CLI 설계 원칙

파일 위치: `docs/adr/0003-cli-design-principles.md`

npx github: 직접 배포와 AI 없는 순수 파일 배달부 채택 결정을 하나의 ADR로 묶음.
두 결정이 같은 맥락("CLI는 단순해야 한다")에서 나왔기 때문.

내용:
- 컨텍스트: greenfield setup CLI 설계
- 결정 1: npm publish 없이 npx github: 직접 참조
- 결정 2: CLI에 AI/LLM 없음 — 순수 파일 배달부
- 근거: 외부 의존성 최소화, 투명성, 유지보수 비용

#### ADR-0004: SHA 기반 lock 정책

파일 위치: `docs/adr/0004-sha-based-lock.md`

내용:
- 컨텍스트: 스킬 설치 시점 재현성
- 결정: semver 태그 대신 commit SHA로 lock
- 근거: 태그는 force-push로 바뀔 수 있음, SHA는 불변
- 결과: `skills-lock.json`의 `ref` 필드

---

### 그룹 C — 스킬 2개 (병렬 가능)

#### `skills/skill-creator/SKILL.md` (신규)

agent-foundry에 스킬을 추가/수정할 때 따르는 가이드. README와 AGENTS.md에서 "skill-creator 우선 사용"이라고 명시하지만 실제로 없는 가장 큰 갭.

**manifests/skills.json 등록 여부: 등록하지 않는다.**
skill-creator는 agent-foundry 레포 기여자(사람 또는 AI)가 스킬 작성 시 참조하는 메타 가이드다.
대상 프로젝트에 배포할 스킬이 아니므로 manifests에 등록하지 않는다.

내용:
- 스킬 디렉토리 구조 (`SKILL.md`, `references/`, `scripts/`, `assets/`)
- frontmatter 형식 필수 필드 (`name`, `description`)
- SKILL.md 작성 원칙 (트리거 조건, 규칙, 예시 포함)
- references/ 사용 기준 (500자 초과 상세 내용은 분리)
- 완료 체크리스트: SKILL.md 작성 → manifests/skills.json 등록 → smoke test 통과

#### `skills/vercel-react-best-practices/SKILL.md` (thin adapter로 교체)

직접 작성하지 않고 외부 원본 스킬을 참조하는 thin adapter로 교체.
이중 관리를 피하고 YAGNI 원칙을 따름.

외부 레포: `https://github.com/vercel-labs/agent-skills` (23k stars, 실재 확인됨)

내용:
- 외부 스킬 설치 명령: `npx skills add https://github.com/vercel-labs/agent-skills --skill react-best-practices`
- 핵심 원칙 3-4줄 요약 (Server/Client Component 분리, RSC data fetching, 번들 최적화)
- "자세한 내용은 외부 스킬 설치 후 참고" 안내
- 주의: 외부 스킬 `react-best-practices` 슬러그 존재 여부를 작성 시점에 레포에서 확인 후 기재

---

## Part 3: 병렬 실행 그룹

3개 그룹 내 항목들은 서로 의존성 없음 → 동시 실행 가능.
그룹 간에도 의존성 없음 → 전체 7개 항목 병렬 실행 가능.

```
그룹 A (문서 3개)          그룹 B (ADR 2개)          그룹 C (스킬 2개)
├── CLAUDE.md              ├── ADR-0003               ├── skill-creator
├── AGENTS.md              └── ADR-0004               └── vercel-react (thin)
└── CONTRIBUTION.md
```

---

## 결정 요약

| 결정 | 선택 | 근거 |
|------|------|------|
| CLAUDE.md vs AGENTS.md | 경계 명확 분리 | Claude Code 전용 vs 에이전트 독립 |
| vercel-react-best-practices | thin adapter | YAGNI, 이중 관리 방지 |
| ADR 0003+0004 분리 기준 | CLI 설계 원칙 하나로 묶음, lock은 별도 | 맥락이 다름 |
| skill-creator 범위 | 가이드 + 완료 체크리스트 | 실용성 우선 |
