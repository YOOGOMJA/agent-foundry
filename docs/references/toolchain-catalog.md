# Toolchain Catalog — Autonomous Dev Pipeline

> 각 도구의 목적, 출처, 성숙도, 리스크, 대안을 포함한다.

| # | 카테고리 | 항목 수 | 핵심 |
|---|---------|--------|------|
| 1 | [Claude Code 스킬](#1-claude-code-스킬-skills) | 16 스킬 | PM, 개발, FSD, 디자인, 테스트, ADR |
| 2 | [MCP 서버](#2-mcp-서버) | 3+3 | shadcn, adrflow, Playwright + 안정화 후 |
| 3 | [메모리/컨텍스트](#3-메모리컨텍스트-유지) | 3 Layer | 파일 → Engram → Qdrant |
| 4 | [CLI/린터](#4-cli--린터-packagejson-devdependencies) | 10+ | 아키텍처, 코드 품질, VRT |
| 5 | [무인 실행](#5-무인-실행-도구) | CLI + 스크립트 | orchestrate.sh, ralph-loop.sh |
| 6 | [프로젝트 스캐폴딩](#6-프로젝트-스캐폴딩-참고) | 3 템플릿 | Turborepo+Next+NestJS 참고 |
| 7 | [제거한 도구](#7-검토-후-제거한-도구) | 6 | kern, pickle-rick, claude-mem 등 |
| 8 | [도입 타임라인](#8-도입-타임라인) | 3단계 | 즉시 → 프로젝트 시작 → 안정화 후 |

---

## 1. Claude Code 스킬 (Skills)

### PM 영역

| 스킬 | 출처 | 설치수/Stars | 설치 | 비고 |
|------|------|-------------|------|------|
| **pm-skills** (8 플러그인, 65 스킬, 36 워크플로우) | [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | 7,433★ | `claude plugin marketplace add phuryn/pm-skills` | MIT. 콘텐츠 전용, 런타임 의존성 없음 |

주요 커맨드:
- `/discover` — 디스커버리 사이클 (아이데이션 → 가정 매핑 → 우선순위화 → 실험 설계)
- `/research-users` — 페르소나, 세그먼테이션, 여정 맵
- `/strategy` — 전략 캔버스, SWOT, Porter
- `/write-prd` — PRD 생성
- `/plan-okrs` — OKR 설정
- `/write-stories` — 유저/잡 스토리
- `/competitive-analysis` — 경쟁 분석
- `/sprint` — 스프린트 계획

프레임워크: Teresa Torres (Continuous Discovery), Marty Cagan (INSPIRED), Alberto Savoia (Pretotyping)

### 개발 워크플로우

| 스킬 | 출처 | Stars | 설치 | 비고 |
|------|------|-------|------|------|
| **superpowers** (14 스킬) | [obra/superpowers](https://github.com/obra/superpowers) | 29,000+★ | 이미 설치됨 (v5.0.2) | MIT. 공식 마켓플레이스 |

포함 스킬:
- `brainstorming` — 소크라틱 디자인 정제, 2-3개 접근법 제안
- `writing-plans` — 2-5분 단위 태스크 분해, 파일 경로/코드 포함
- `executing-plans` — 배치 실행 + 체크포인트
- `subagent-driven-development` — 병렬 서브에이전트, 2단계 리뷰
- `test-driven-development` — RED-GREEN-REFACTOR 강제
- `systematic-debugging` — 4단계 근본원인 분석
- `requesting-code-review` / `receiving-code-review`
- `using-git-worktrees` — 격리된 병렬 개발
- `finishing-a-development-branch` — 머지/PR/정리
- `dispatching-parallel-agents` — 동시 서브에이전트
- `verification-before-completion` — 증거 기반 완료 확인
- `writing-skills` — 신규 스킬 작성 가이드

### FSD 아키텍처

| 스킬 | 출처 | Stars | 설치 | 비고 |
|------|------|-------|------|------|
| **feature-sliced/skills** | [feature-sliced/skills](https://github.com/feature-sliced/skills) | 9★ (공식 조직) | `npx skills add feature-sliced/skills` | FSD v2.1 규칙. 공식 FSD 조직 관리 |

### 디자인 시스템

| 스킬 | 출처 | 설치수 | 설치 | 역할 |
|------|------|--------|------|------|
| **shadcn** (공식) | [shadcn/ui](https://github.com/shadcn/ui) | 21.2K | `npx skills add https://github.com/shadcn/ui --skill shadcn` | 컴포넌트 선택, CLI 가이드 |
| **tailwind-design-system** | [wshobson/agents](https://github.com/wshobson/agents) | 19.3K | `npx skills add https://github.com/wshobson/agents --skill tailwind-design-system` | Tailwind v4 토큰, OKLCH, CVA 패턴 |
| **frontend-design-system** | [supercent-io/skills-template](https://github.com/supercent-io/skills-template) | 7.9K | `npx skills add https://github.com/supercent-io/skills-template --skill frontend-design-system` | 전체 토큰 시스템 + WCAG 2.1 AA |

### 테스팅

| 스킬 | 출처 | 설치수 | 설치 | 역할 |
|------|------|--------|------|------|
| **webapp-testing** | [anthropics/skills](https://github.com/anthropics/skills) (공식) | 24.8K | `npx skills add https://github.com/anthropics/skills --skill webapp-testing` | Playwright 기반 로컬 웹앱 테스트 + 스크린샷 |

### ADR / 계획 / 세션 관리

| 스킬/플러그인 | 출처 | 설치 | 역할 |
|-------------|------|------|------|
| **zircote/adr** | [zircote/adr](https://github.com/zircote/adr) | `claude plugin marketplace add zircote/adr` | 7 ADR 포맷, adr-compliance 에이전트, `/adr:new` |
| **planning-with-files** | [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | `npx skills add OthmanAdi/planning-with-files -g` | PreToolUse 훅으로 plan 리마인드 (16.2K★) |
| **Cozempic** | [Ruya-AI/cozempic](https://github.com/Ruya-AI/cozempic) | `claude plugin marketplace add Ruya-AI/cozempic` | 세션 프루닝, 13개 전략, 22% 크기 절감 |

---

## 2. MCP 서버

| MCP | 출처 | Stars | 설정 | 역할 | 리스크 |
|-----|------|-------|------|------|--------|
| **shadcn-ui-mcp-server** | [Jpisnice/shadcn-ui-mcp-server](https://github.com/Jpisnice/shadcn-ui-mcp-server) | 2,702★ | `.mcp.json` | shadcn v4 컴포넌트 소스/메타데이터. React/Svelte/Vue/RN | 낮음-중간 |
| **adrflow** | [memvid/adrflow](https://github.com/memvid/adrflow) | — | `{"command": "npx", "args": ["-y", "adrflow"]}` | ADR 자동 감지/기록/검색. FTS | 낮음 |
| **Playwright** | microsoft/playwright-mcp | 29,046★ | 이미 설치됨 | E2E + VRT + 브라우저 자동화 | 낮음 |

### 안정화 후 추가

| MCP | 출처 | 시점 | 역할 |
|-----|------|------|------|
| **@storybook/addon-mcp** (공식) | Storybook 팀 | 공개 시 | Storybook 컴포넌트 메타데이터 + 자율 테스트 루프 |
| **Qdrant MCP** | [qdrant/mcp-server-qdrant](https://github.com/qdrant/mcp-server-qdrant) | 시맨틱 검색 필요 시 | 임베딩 기반 시맨틱 메모리 검색 |
| **Figma MCP** (공식) | Figma 팀 | Figma 연동 시 | 디자인 파일 접근 |

---

## 3. 메모리/컨텍스트 유지

### Layer 1: 파일 시스템 (즉시, 무료)

| 파일 | 역할 |
|------|------|
| `CLAUDE.md` | 프로젝트 규칙. 압축 후에도 유지 |
| `docs/adr/` | 아키텍처/제품 결정 기록 |
| `docs/prd.md` | PM 산출물 |
| `docs/plan.md` | Superpowers 구현 계획 |
| `.ralph/progress.txt` | Ralph Loop 반복 상태 |

### Layer 2: Engram (프로젝트 시작 시)

| 항목 | 내용 |
|------|------|
| 출처 | [Gentleman-Programming/engram](https://github.com/Gentleman-Programming/engram) |
| Stars | 1,479★ |
| 설치 | `brew install gentleman-programming/tap/engram` |
| 저장 | SQLite + FTS5 (단일 파일 `~/.engram/engram.db`) |
| 의존성 | Go 바이너리 하나 (제로 의존성) |
| 라이선스 | MIT |
| MCP 도구 | `mem_save`, `mem_search`, `mem_update`, `mem_delete`, `mem_context`, `mem_timeline` 등 13개 |
| 에이전트 호환 | Claude Code, Codex, Gemini CLI, Cursor, Windsurf 등 모든 MCP 에이전트 |
| 리스크 | 중간 (1개월차, 장기 유지보수 미검증). Layer 1만으로도 동작하므로 폴백 보장 |

### Layer 3: Qdrant MCP (대규모화 시)

| 항목 | 내용 |
|------|------|
| 출처 | [qdrant/mcp-server-qdrant](https://github.com/qdrant/mcp-server-qdrant) |
| 설치 | `pip install mcp-server-qdrant` |
| 용도 | 시맨틱 검색 (임베딩 기반). "이전에 비슷한 문제를 어떻게 풀었지?" |
| 시점 | 프로젝트 규모가 커져서 FTS 검색으로 부족할 때 |

### 검토 후 탈락

| 도구 | Stars | 탈락 이유 |
|------|-------|----------|
| claude-mem | 36,927★ | AGPL 라이선스, $CMEM 솔라나 토큰, Node+Bun+Python+ChromaDB 의존성, 성능 이슈 보고 |
| CONTINUITY | 0★ | 사실상 포기된 프로젝트 |
| Mem0 | 50,081★ | Docker + LLM API 필요. 코딩 에이전트용으로는 과도한 인프라 |

---

## 4. CLI / 린터 (package.json devDependencies)

### 아키텍처

| 도구 | 출처 | 설치 | 역할 | 리스크 |
|------|------|------|------|--------|
| **steiger** | [feature-sliced/steiger](https://github.com/feature-sliced/steiger) | `npm install -D steiger @feature-sliced/steiger-plugin` | FSD 구조 린트 (public-api, no-cross-imports) | 중간. **비차단으로만** |
| **@feature-sliced/eslint-config** | [feature-sliced/eslint-config](https://github.com/feature-sliced/eslint-config) | `npm install -D @feature-sliced/eslint-config` | FSD import/public-api 규칙 | 낮음 |
| **@feature-sliced/cli** | [feature-sliced/cli](https://github.com/feature-sliced/cli) | `npm install -D @feature-sliced/cli` | 레이어/슬라이스 스캐폴딩 | 낮음 |

### 코드 품질 (Clean Code / FP / SOLID)

| 도구 | 출처 | Stars | 설치 | 역할 |
|------|------|-------|------|------|
| **@typescript-eslint/eslint-plugin** | [typescript-eslint](https://github.com/typescript-eslint/typescript-eslint) | 15K+ | `npm install -D @typescript-eslint/eslint-plugin @typescript-eslint/parser` | naming-convention 규칙 (camelCase, PascalCase, UPPER_CASE) |
| **eslint-plugin-functional** | [eslint-functional](https://github.com/eslint-functional/eslint-plugin-functional) | 966 | `npm install -D eslint-plugin-functional` | FP 강제: no-mutation, no-let, no-class. `recommended` 프리셋 사용 |
| **eslint-plugin-sonarjs** | [SonarSource](https://github.com/SonarSource/eslint-plugin-sonarjs) | 1.2K | `npm install -D eslint-plugin-sonarjs` | 인지 복잡도, 동일 함수, 중복 감지 |
| **jscpd** | [kucherenko/jscpd](https://github.com/kucherenko/jscpd) | 5.4K | `npm install -D jscpd` | DRY 위반 감지 (copy-paste detection) |

### 상태 관리 린트 (선택)

| 도구 | 출처 | Stars | 설치 | 역할 |
|------|------|-------|------|------|
| **eslint-plugin-xstate** | [rlaffers/eslint-plugin-xstate](https://github.com/rlaffers/eslint-plugin-xstate) | 50 | `npm install -D eslint-plugin-xstate` | XState v4+v5 린트 (18 규칙) |
| **eslint-plugin-rxjs** | [cartant/eslint-plugin-rxjs](https://github.com/cartant/eslint-plugin-rxjs) | 316 | `npm install -D eslint-plugin-rxjs` | RxJS 린트 (no-nested-subscribe 등) |

> `eslint-plugin-functional`의 strict 모드는 shadcn 컴포넌트(class 사용)나 Next.js 내부와 충돌할 수 있음. `recommended` 프리셋 + `overrides`로 packages/ui, apps/web/app/은 완화.

### VRT

| 도구 | 출처 | 설치 | 역할 | 리스크 |
|------|------|------|------|--------|
| **lost-pixel** | [lost-pixel/lost-pixel](https://github.com/lost-pixel/lost-pixel) | `npm install -D lost-pixel` | Storybook VRT. 무료 7K 스냅샷/월 | 중간-높음. **비차단 리포트로만** (플래키 이슈 #429) |

### 코드 품질 스킬 (AI 판단 기반)

| 스킬 | 출처 | Stars/Installs | 설치 | 역할 |
|------|------|---------------|------|------|
| **coding-conventions** (커스텀) | skills/coding-conventions/ (이 청사진 내) | — | 프로젝트 스킬 경로로 복사 | 명명, FP, FSD public API, Zustand/XState 패턴, SOLID |
| **ai-craftsman-superpowers** | [BULDEE/ai-craftsman-superpowers](https://github.com/BULDEE/ai-craftsman-superpowers) | 3★ | `/plugin marketplace add BULDEE/ai-craftsman-superpowers` | Clean Architecture, DDD, SOLID, YAGNI, TDD |
| **context-engineering-kit** (SDD) | [NeoLabHQ/context-engineering-kit](https://github.com/NeoLabHQ/context-engineering-kit) | 651★ | `/plugin install sdd@NeoLabHQ/context-engineering-kit` | DDD + SOLID + 코드 리뷰 에이전트 |
| **react-best-practices** | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | 216K installs | `npx skills add https://github.com/vercel-labs/agent-skills --skill react-best-practices` | React 성능/조합 패턴 |

> YAGNI는 정적 분석으로 강제 불가 — coding-conventions 스킬 + 코드 리뷰 스킬로 커버.
> Zustand 슬라이스 패턴도 전용 린터 없음 — coding-conventions 스킬의 references/zustand-patterns.md에 패턴 명시.

---

## 5. 무인 실행 도구

### Claude Code CLI 플래그

| 플래그 | 용도 |
|--------|------|
| `-p` / `--print` | 비대화형 헤드리스 모드 |
| `--dangerously-skip-permissions` | 모든 권한 프롬프트 스킵 (무인 필수) |
| `--max-turns N` | 에이전트 턴 제한 (20-40 권장) |
| `--max-budget-usd N` | 세션당 비용 하드캡 (API 모드에서만) |
| `--worktree NAME` | 격리된 git worktree에서 실행 |
| `--allowedTools "..."` | 특정 도구만 허용 |
| `MAX_THINKING_TOKENS=8000` | 사고 토큰 제한 (-30% 출력 비용) |

### 오케스트레이션

| 도구 | 단계 | 역할 |
|------|------|------|
| `scripts/orchestrate.sh` | 즉시 | Phase 전환, 게이트 폴링, 병렬 실행 |
| `scripts/ralph-loop.sh` | 즉시 | 품질 수렴 반복 (max 5회, Pickle Rick 대체) |
| `scripts/merge-worktree.sh` | 즉시 | worktree → main 머지 |
| **Agent SDK** (TS/Py) | 안정화 후 | 프로그래밍 오케스트레이터 (`@anthropic-ai/claude-agent-sdk`) |

### GitHub 연동

| 도구 | 역할 |
|------|------|
| `gh` CLI | Issue 생성/폴링, PR 생성, 게이트 대기 |
| **claude-code-action** | [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) (6.3K★). GitHub Actions에서 @claude 트리거 |

---

## 6. 프로젝트 스캐폴딩 참고

### 템플릿 레퍼런스

| 레포 | Stars | 구성 | URL |
|------|-------|------|-----|
| **fullstack-starter** | 2★ | Next.js 15 + NestJS + Prisma + PostgreSQL + Turborepo | [JoaquinVilchez/fullstack-starter](https://github.com/JoaquinVilchez/fullstack-starter) |
| **turborepo-nestjs** | 22★ | Turborepo + NestJS + Next.js + Prisma + MongoDB + RabbitMQ | [fajarnugraha37/turborepo-nestjs](https://github.com/fajarnugraha37/turborepo-nestjs) |
| **create-next-claude-app** | 8★ | Next.js + FSD + CLAUDE.md | [Cluster-Taek/create-next-claude-app](https://github.com/Cluster-Taek/create-next-claude-app) |

> Turborepo + Next.js + NestJS + FSD 통합 템플릿은 존재하지 않음. 위 레퍼런스 조합으로 직접 구성 필요.

### Figma → shadcn 파이프라인 (Optional)

| 도구 | 설명 |
|------|------|
| **midas-uiux-pipeline** | [shin-hyuk/midas-uiux-pipeline](https://github.com/shin-hyuk/midas-uiux-pipeline). Figma MCP + shadcn MCP + ReactBits MCP 3개 조합 |
| **Figma MCP** (공식) | Figma 디자인 파일 접근 |

---

## 7. 검토 후 제거한 도구

| 도구 | Stars | 제거 이유 |
|------|-------|----------|
| **kern** | 0★ | 5주차, 검증 제로. 25개 스캐너 주장하지만 커뮤니티 없음 |
| **pickle-rick-claude** | 11★ | 25일차, "Fake Ralph Loop" 비판. 직접 구현 ralph-loop.sh로 대체 |
| **mcpland/storybook-mcp** | 44★ | 공식 @storybook/addon-mcp로 대체 예정 |
| **mcp-design-system-extractor** | 58★ | 단독 관리자, Puppeteer 의존, 필수 아님 |
| **Agent Teams** (현재) | 실험적 | 컨텍스트 압축 시 팀 상태 소멸, worktree 격리 미작동, TeamCreate 무음 종료 |
| **claude-mem** | 36,927★ | AGPL, $CMEM 크립토 토큰, 무거운 의존성, 성능 이슈 |

---

## 8. 도입 타임라인

```
즉시 (파이프라인 설계 단계)
├── phuryn/pm-skills
├── superpowers (설치됨)
├── feature-sliced/skills
├── shadcn + tailwind-design-system + frontend-design-system
├── webapp-testing
├── adrflow (MCP)
├── zircote/adr
├── planning-with-files
├── Cozempic
├── shadcn-ui-mcp-server (MCP)
└── Playwright (설치됨)

프로젝트 시작 시 (스캐폴딩)
├── Engram (메모리 Layer 2)
├── steiger + @feature-sliced/steiger-plugin
├── @feature-sliced/eslint-config
├── @feature-sliced/cli
├── lost-pixel
├── scripts/orchestrate.sh
├── scripts/ralph-loop.sh
└── scripts/merge-worktree.sh

안정화 후 (선택적)
├── @storybook/addon-mcp (공개 시)
├── Qdrant MCP (시맨틱 검색 필요 시)
├── Agent SDK 오케스트레이터 (쉘 한계 시)
├── Agent Teams (치명적 버그 수정 시)
└── Figma MCP (디자이너 협업 시)
```
