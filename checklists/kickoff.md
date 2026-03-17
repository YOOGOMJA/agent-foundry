# Kickoff Checklist

프로젝트 시작 시 순서대로 실행.

## 1. 스킬 설치

- [ ] `claude plugin marketplace add phuryn/pm-skills`
- [ ] `npx skills add feature-sliced/skills`
- [ ] `npx skills add https://github.com/shadcn/ui --skill shadcn`
- [ ] `npx skills add https://github.com/wshobson/agents --skill tailwind-design-system`
- [ ] `npx skills add https://github.com/supercent-io/skills-template --skill frontend-design-system`
- [ ] `npx skills add https://github.com/anthropics/skills --skill webapp-testing`
- [ ] `npx skills add OthmanAdi/planning-with-files -g`
- [ ] `claude plugin marketplace add zircote/adr`
- [ ] `claude plugin marketplace add Ruya-AI/cozempic`
- [ ] superpowers 설치 확인 (`/plugin list`)
- [ ] coding-conventions 스킬 설치 (skills/coding-conventions/ → 프로젝트 스킬 경로로 복사)

### 선택 스킬
- [ ] (선택) `/plugin marketplace add BULDEE/ai-craftsman-superpowers`
- [ ] (선택) `/plugin install sdd@NeoLabHQ/context-engineering-kit`
- [ ] (선택) `npx skills add https://github.com/vercel-labs/agent-skills --skill react-best-practices`

## 2. MCP 설정

- [ ] `templates/mcp.json.tmpl` → `.mcp.json`으로 복사
- [ ] GITHUB_TOKEN 설정 확인
- [ ] Engram 설치: `brew install gentleman-programming/tap/engram`

## 3. 프로젝트 스캐폴딩

- [ ] `npx create-turbo@latest`
- [ ] `npx @feature-sliced/cli generate` (apps/web)
- [ ] `npx shadcn-ui@latest init` (packages/ui)
- [ ] `npx storybook@latest init` (packages/ui)
- [ ] `nest new api` (apps/api)
- [ ] `npm install -D steiger @feature-sliced/steiger-plugin`
- [ ] `npm install -D @feature-sliced/eslint-config`
- [ ] `npm install -D @typescript-eslint/eslint-plugin @typescript-eslint/parser`
- [ ] `npm install -D eslint-plugin-functional eslint-plugin-sonarjs jscpd`
- [ ] `npm install -D lost-pixel`
- [ ] (선택) `npm install -D eslint-plugin-xstate` 또는 `eslint-plugin-rxjs`
- [ ] packages/types/ 구조 생성

## 4. CLAUDE.md 설정

- [ ] `templates/CLAUDE.md.tmpl` → `CLAUDE.md`로 복사
- [ ] {{PROJECT_NAME}} 치환
- [ ] 프로젝트 특화 규칙 추가

## 5. 오케스트레이터 설정

- [ ] `scripts/orchestrate.sh` 복사 + 실행 권한
- [ ] `scripts/ralph-loop.sh` 복사 + 실행 권한
- [ ] `scripts/merge-worktree.sh` 복사 + 실행 권한
- [ ] `gh` CLI 인증 확인 (`gh auth status`)

## 6. 핸드오프 템플릿 설정

- [ ] `templates/handoff/` → `docs/templates/`로 복사

## 7. 목표 작성

- [ ] `docs/goal.md` 작성 (templates/handoff/goal.md 참조)

## 8. 파이프라인 실행

- [ ] `./scripts/orchestrate.sh`
