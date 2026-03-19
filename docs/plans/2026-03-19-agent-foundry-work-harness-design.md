# Agent Foundry 작업 하네스 설계 (개인 시작 자동화)

- Date: 2026-03-19
- Owner: Codex
- 상태: Draft (self-reviewed)

## 1) 목표

`agent-foundry`를 "새 프로젝트 시작 직후 작업 하네스"로 동작시키는 설계를 확정한다.

핵심 방향:

1. `init` 중심이 아니라 `skills search/install + audit + docs suggest/write` 중심
2. 하이브리드 소스 지원: curated(manifest) + external(Git URL/repo)
3. 개인 1인 워크플로우 최적화: 핵심만 자동 설치, 나머지는 선택 설치
4. 누락 문서 자동 점검/생성으로 시작 품질 상향

## 2) 현재 코드 진단 (실행 검증 기반)

실행 검증으로 확인된 문제:

1. 템플릿 소스가 이원화되어 CLI와 Bash 동작이 다름
2. README 예시와 `manifests/skills.json` 불일치
3. lock 정책(ADR-0004 SHA 기반)과 실제 lock 출력이 다름
4. smoke test가 핵심 회귀(README 예시, lock 스키마, CLI/Bash parity)를 검출하지 못함

결론: 현재 상태는 "부분 동작"이며 작업 하네스로 운영하기엔 정합성 보완이 선행되어야 한다.

## 3) 외부 생태계 검증 요약

### 3.1 설치 경로는 단일하지 않음

1. `anthropics/skills`는 Claude Code plugin marketplace 경로를 공식 안내
2. `skills` CLI(`npx skills add ...`)는 별도 open ecosystem 경로로 GitHub/Git URL 설치를 지원

따라서 agent-foundry는 외부 설치 방식을 단일로 가정하면 안 되며, 설치 adapter 구조가 필요하다.

### 3.2 Agent Skills 표준 요구사항

1. 스킬 최소 구조: `SKILL.md` + optional `scripts/`, `references/`, `assets/`
2. `name`/`description` 제약(길이/형식)
3. `.agents/skills/` 경로의 상호운용 스캔 관례
4. 프로젝트-level 스킬 신뢰도(트러스트) 점검 권장

### 3.3 보안/신뢰

외부 디렉토리는 감사 정보가 있어도 완전 보장되지 않는다. 설치 전후 로컬 점검과 명시적 동의가 필요하다.

## 4) 최종 설계

### 4.1 아키텍처 원칙

1. 얇은 CLI + 기능 모듈 분리
2. manifest 단일 진실원천(templates/skills/catalog)
3. lock 기반 재현성 유지 + 하위 호환 마이그레이션
4. 질문은 한 번에 하나만, `--yes` 시 합리적 기본값 자동 선택

### 4.2 CLI 인터페이스

1. `agent-foundry skills search [query] [--source curated|external|all]`
2. `agent-foundry skills install <name-or-url> [--skill <name>] [--allow-external] [--yes]`
3. `agent-foundry audit [--repo <path>] [--format text|json]`
4. `agent-foundry docs suggest [--repo <path>]`
5. `agent-foundry docs write <doc-type> [--repo <path>] [--yes]`

`init` 신규 추가는 하지 않는다. 기존 템플릿 설치는 `skills install + docs write` 조합으로 대체한다.

### 4.3 설치 adapter 계층

설치 경로를 adapter로 분리한다.

1. `local-copy`:
   - curated 로컬 스킬(`manifests/skills.json`) 설치
   - 대상 경로: `<project>/.agents/skills/<skill-name>`
2. `git-copy`:
   - external GitHub/Git URL에서 clone 후 지정 스킬 디렉토리 복사
3. `plugin-marketplace`:
   - Claude plugin marketplace 설치 커맨드를 "실행 안내"로 제공
   - CLI가 직접 `/plugin`을 호출하지 않고 사용자 액션을 요구
4. `skills-cli`(선택):
   - `npx skills add`를 통한 외부 설치를 passthrough 옵션으로 지원 가능

기본 정책은 `local-copy`, external은 `--allow-external` 명시 시만 활성화한다.

### 4.4 카탈로그/manifest 모델

`manifests/catalog.json` 신설:

1. curated 스킬 메타데이터 (`name`, `description`, `path`, `trust=curated`)
2. 추천 external 엔트리 (`source`, `install.kind`, `repo`, `skill`, `trust`, `notes`)
3. 문서 템플릿 매핑 (`doc-type -> source template path -> destination path`)

기존 `manifests/skills.json`과 `manifests/templates.json`은 즉시 제거하지 않고 호환 레이어를 둔다.

### 4.5 lock 스키마(v2)

`skills-lock.json` v2:

1. `schemaVersion`
2. `installedAt`
3. `source` (agent-foundry source)
4. `ref` (SHA, 로컬이면 git HEAD 시도 후 실패 시 `local`)
5. `template`
6. `skills` (curated install records)
7. `externals` (repo URL, ref, skill names, install adapter)

`update-skills`는 v1/v2 둘 다 읽고 v2로 재기록한다.

### 4.6 audit 엔진

검사 축:

1. 구조 정합성
   - manifests ↔ 실제 디렉토리 일치
   - 템플릿 참조 파일 존재
2. 문서 준비도
   - `docs/goal.md`, `docs/prd.md`, `docs/architecture.md`, `docs/screen-spec.md`, `docs/api-spec.md`, `docs/adr/` 등
3. lock/재현성
   - lock 필드 유효성, ref 형식 점검
4. 신뢰/보안
   - external skill 출처 표시, 실행 스크립트 존재 여부 경고
5. 결과 형식
   - `PASS/WARN/FAIL`, code 기반 출력 + 제안 명령(`docs suggest`, `docs write ...`)

### 4.7 docs suggest/write

`docs suggest`:

1. audit 결과 + 템플릿 매핑으로 누락 문서 우선순위 제안
2. "왜 필요한지"와 "어느 템플릿에서 생성하는지" 함께 출력

`docs write`:

1. 템플릿 복사 + 플레이스홀더 치환
2. 필수 입력이 없으면 질문 1개씩 진행
3. `--yes`면 TODO 마커 포함 기본값으로 즉시 생성

### 4.8 오류 처리

1. unknown skill/template: 유사 키워드 후보 제시
2. external fetch 실패: URL/권한/네트워크 원인 분리
3. malformed `SKILL.md`: skip + 진단 로그 출력
4. partial failure: 성공 항목 유지 + 실패 항목 재시도 커맨드 출력

## 5) 구현 전 변경 맵

필수 변경:

1. `bin/agent-foundry.js` (서브커맨드 라우팅)
2. `manifests/skills.json` (등록 정합성 보정)
3. `manifests/templates.json` (단일 기준 정리 또는 catalog로 이관)
4. `scripts/bootstrap-project.sh` (legacy wrapper화 또는 제거)
5. `scripts/update-skills.sh` (lock v2 대응)
6. `README.md` (실제 동작 커맨드와 정합)
7. `tests/smoke/*` (회귀 테스트 확대)

신규 파일(권장):

1. `manifests/catalog.json`
2. `lib/catalog.js`
3. `lib/installer.js`
4. `lib/auditor.js`
5. `lib/doc-writer.js`
6. `lib/prompt.js`

## 6) 테스트 전략

최소 검증 세트:

1. CLI contract:
   - `skills search/install/audit/docs` 정상/오류 경로
2. 정합성:
   - README 예시 커맨드 실제 성공
   - templates/skills manifest parity
3. lock:
   - v1 입력 -> v2 마이그레이션
   - SHA/ref 기록 검증
4. external:
   - 로컬 fixture git repo로 external install 테스트 (네트워크 의존 제거)
5. docs:
   - `docs suggest` 누락 탐지
   - `docs write --yes` 비대화형 생성

## 7) 범위 제한 (YAGNI)

이번 단계에서 제외:

1. 원격 registry 서버 구축
2. 점수 기반 추천 모델
3. LLM 기반 문서 자동 내용 생성
4. 플랫폼별 고급 permission UI

## 8) 완료 기준

다음 조건을 만족하면 설계 단계 완료로 본다.

1. CLI/Bash 경로 이원화 해소 방안 확정
2. lock 정책과 구현 설계 합의(SHA + 호환)
3. hybrid 설치 정책(allow-external + trust 경고) 확정
4. audit/docs 흐름으로 누락 문서 보완 가능
5. 구현 변경 파일과 테스트 전략이 파일 단위로 명확

## 9) 근거 소스

1. Agent Skills spec: https://agentskills.io/specification
2. Agent Skills integration guide: https://agentskills.io/client-implementation/adding-skills-support
3. Anthropic skills repo: https://github.com/anthropics/skills
4. Anthropic raw README: https://raw.githubusercontent.com/anthropics/skills/main/README.md
5. Anthropic webapp-testing skill: https://raw.githubusercontent.com/anthropics/skills/main/skills/webapp-testing/SKILL.md
6. Vercel agent-skills repo: https://github.com/vercel-labs/agent-skills
7. Vercel raw README: https://raw.githubusercontent.com/vercel-labs/agent-skills/main/README.md
8. Vercel react-best-practices skill: https://raw.githubusercontent.com/vercel-labs/agent-skills/main/skills/react-best-practices/SKILL.md
9. Vercel blog (react-best-practices): https://vercel.com/blog/introducing-react-best-practices
10. skills.sh docs: https://skills.sh/docs
11. skills CLI docs: https://skills.sh/docs/cli
12. skills CLI repo README: https://raw.githubusercontent.com/vercel-labs/skills/main/README.md
13. skills.sh security/audits: https://skills.sh/audits
