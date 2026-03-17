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

```
bash tests/smoke/run-all.sh
```
