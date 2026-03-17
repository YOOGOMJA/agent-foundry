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

```
bash tests/smoke/run-all.sh
```

## 커밋 컨벤션
feat / fix / docs / chore — conventional commits 형식
