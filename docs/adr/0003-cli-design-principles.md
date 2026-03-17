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
