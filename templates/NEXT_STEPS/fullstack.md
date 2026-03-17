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

## 4. 파이프라인 프롬프트 작성

`scripts/orchestrate.sh`는 `prompts/` 아래 phase별 프롬프트 파일이 있어야 실행됩니다.
각 파일은 프로젝트 특화 내용이므로 직접 작성하세요.

~~~bash
mkdir -p prompts
# 아래 6개 파일 작성 (docs/templates/ 핸드오프 템플릿 참고)
touch prompts/phase1-pm.md
touch prompts/phase2a-architect.md
touch prompts/phase2b-designer.md
touch prompts/phase3-fe-developer.md
touch prompts/phase3-be-developer.md
touch prompts/phase4-tester.md
~~~

각 파일에 해당 phase의 AI 에이전트에게 전달할 프롬프트를 작성합니다.

## 5. 목표 작성 후 파이프라인 시작

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
