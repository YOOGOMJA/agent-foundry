# agent-foundry 도메인 독립 Skills Hub 설계

- Date: 2026-03-16
- Owner: kyeongsoo-yoo
- 상태: 승인됨(브레인스토밍 완료)

## 1) 배경과 목표

새 프로젝트를 시작할 때마다 `AGENTS.md`와 재사용 가능한 스킬 구성을 반복 작성하는 비용을 줄인다.
이 저장소를 공개 레포로 운영하되, 1차 목적은 개인 워크플로우 최적화로 둔다.

핵심 목표는 다음과 같다.

- 도메인 독립 스킬을 허브 형태로 중앙 관리
- 프로젝트별로 필요한 스킬만 선택 설치
- `AGENTS.md`를 템플릿 기반으로 빠르게 생성
- 설치 시점 버전을 고정(lock)하여 재현성 보장

## 2) 접근 방식 비교

### 옵션 A) Tag 기반 Hub + lock 파일 (채택)

- 스킬 허브를 버전 태그(`vMAJOR.MINOR.PATCH`)로 배포
- 프로젝트 설치 시점 버전과 커밋을 `skills-lock.json`에 기록
- 필요 시 수동 업데이트

장점:
- 재현성/롤백/디버깅이 명확함
- 공개 레포 운영 시 변경 전파 리스크를 제어 가능

단점:
- 릴리즈 태깅 규율이 필요함

### 옵션 B) main 최신 직접 참조

장점:
- 단순함

단점:
- 프로젝트별 결과가 달라질 수 있어 안정성이 낮음

### 옵션 C) subtree/submodule로 허브 전체 연결

장점:
- 추적성은 높음

단점:
- 매 프로젝트에 과도한 파일이 유입되고 설치 UX가 무거움

## 3) 최종 설계

### 3-1. 아키텍처 원칙

- 운영 모델: 공개 오픈소스 + 개인 워크플로우 우선(opinionated)
- 버전 전략: 기본 고정 버전(lock), 수동 업그레이드
- 자동화 범위(MVP): `스킬 설치 + AGENTS 생성`

### 3-2. 저장소 구성

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

### 3-3. 핵심 컴포넌트 책임

- `skills/`: 도메인 독립 재사용 스킬 본문과 보조 자료 저장
- `templates/agents/`: 프로젝트별 `AGENTS.md` 생성 템플릿
- `manifests/skills.json`: 설치 가능한 스킬 인덱스와 메타데이터
- `scripts/bootstrap-project.sh`: 초기 설치/생성/lock 작성 오케스트레이션
- `scripts/install-skill.sh`: 단일 스킬 선택 설치
- `scripts/update-skills.sh`: lock 기반 수동 업데이트

### 3-4. 문서/거버넌스 원칙

- 공식 문서는 한글로 작성
- 작업 흐름은 `Issue -> Plan -> Branch/Worktree -> Commit -> PR` 고정
- `CONTRIBUTION.md`에 브랜치/커밋/PR/검증 규칙 명시
- 아키텍처/운영 결정은 `docs/adr/`에 기록
- 스킬 생성/수정은 `skill-creator` 우선 사용 규칙을 `AGENTS.md`에 명시

## 4) 데이터 흐름

1. 새 프로젝트에서 bootstrap 스크립트 실행
2. `manifests/skills.json` 조회
3. 선택한 스킬 설치
4. 템플릿 조합으로 `AGENTS.md` 생성
5. 설치 버전/커밋을 프로젝트 `skills-lock.json`에 기록

## 5) 오류 처리 정책

- 존재하지 않는 스킬/버전 요청 시 실패 처리 + 대체 버전 안내
- 이미 설치된 스킬은 덮어쓰기 옵션으로 제어
- lock 불일치 시 자동 강제 업데이트 금지, 명시적 `update` 실행 요구

## 6) 테스트 및 검증 기준

- 스크립트 스모크: 설치/업데이트/재실행(idempotent)
- 샘플 프로젝트 재현성: lock 기준 재설치 결과 동일성 확인
- 문서/템플릿 유효성: 경로/링크/필수 항목 검사

## 7) MVP 범위와 제외 범위

MVP 포함:
- 스킬 선택 설치
- `AGENTS.md` 템플릿 생성
- `skills-lock.json` 기록

MVP 제외:
- 대규모 자동 리팩터링
- 복잡한 원격 동기화 충돌 자동 해결
- 전체 품질 게이트 자동 실행

## 8) 후속 계획

브레인스토밍 이후 단계로 `writing-plans` 스킬을 사용해 구현 계획 문서를 작성한다.
