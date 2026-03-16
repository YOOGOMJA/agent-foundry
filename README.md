# agent-foundry

도메인과 무관하게 재사용 가능한 AI 스킬과 에이전트 운영 규칙을 모아두는 공개형 허브 저장소입니다.

새 프로젝트를 시작할 때 매번 `AGENTS.md`를 처음부터 작성하지 않고,
필요한 스킬만 가져와 빠르게 프로젝트 규칙을 세팅하는 것을 목표로 합니다.

## MVP 목적

- 새 프로젝트에서 필요한 스킬만 선택 설치한다.
- 템플릿 기반으로 `AGENTS.md`를 자동 생성한다.
- 설치 시점 버전을 `skills-lock.json`에 기록해 재현성을 확보한다.

## 왜 이 저장소를 쓰나

반복되는 시작 작업을 줄입니다.

- 새 프로젝트마다 `AGENTS.md` 초안 작성 반복
- 프로젝트별로 필요한 스킬 수동 복사
- 어떤 버전의 스킬을 썼는지 추적 어려움

`agent-foundry`는 위 문제를 다음 원칙으로 해결합니다.

## 핵심 원칙

1. 고정 버전 우선: 설치 시점 버전을 lock으로 기록
2. 수동 업데이트: 의도적으로 올릴 때만 업그레이드
3. 선택 설치: 필요한 스킬만 가져오기
4. 한국어 문서화: 운영 문서와 가이드는 한국어 기준
5. 표준 흐름: `Issue -> Plan -> Branch/Worktree -> Commit -> PR`
6. 스킬 작성/수정: `skill-creator` 우선 사용

## 목표 구조 (MVP)

```text
agent-foundry/
  skills/
    <skill-name>/
      SKILL.md
      references/
      scripts/
      assets/
  templates/
    agents/
      base.md
      frontend.md
      fullstack.md
  manifests/
    skills.json
  scripts/
    bootstrap-project.sh
    install-skill.sh
    update-skills.sh
  docs/
    adr/
    plans/
  AGENTS.md
  CONTRIBUTION.md
```

## 빠른 시작

### 1) 프로젝트 부트스트랩

```bash
bash scripts/bootstrap-project.sh \
  --repo-root /path/to/agent-foundry \
  --target /path/to/new-project \
  --template frontend \
  --skills vercel-react-best-practices,web-design-guidelines
```

결과 예시:

- `/path/to/new-project/AGENTS.md` 생성
- `/path/to/new-project/.agents/skills/*` 설치
- `/path/to/new-project/skills-lock.json` 생성

### 2) lock 기준 업데이트

```bash
bash scripts/update-skills.sh \
  --repo-root /path/to/agent-foundry \
  --target /path/to/new-project
```

## 버전 고정/업데이트 정책

- 기본 정책은 고정 버전 설치이며, 결과는 `skills-lock.json`에 기록된다.
- 자동 강제 업데이트는 하지 않는다.
- 업데이트가 필요할 때만 `update-skills.sh`를 수동 실행한다.

## 문서

- 설계 문서: `docs/plans/2026-03-16-agent-foundry-skills-hub-design.md`
- 구현 계획: `docs/plans/2026-03-16-agent-foundry-mvp-implementation.md`

## 운영 방향

공개 레포로 운영하되, 1차 목적은 작성자의 실제 개발 워크플로우 최적화입니다.
필요가 맞는 사용자라면 동일한 방식으로 가져다 쓸 수 있게 유지합니다.
