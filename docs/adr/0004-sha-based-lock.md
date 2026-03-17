# ADR-0004: SHA 기반 lock 정책

- 상태: Accepted
- 날짜: 2026-03-17
- 관련: docs/adr/0002-version-lock-policy.md, docs/superpowers/specs/2026-03-17-agent-foundry-greenfield-ai-setup-design.md

## 문맥

스킬 설치 시점의 재현성을 보장하기 위해 `skills-lock.json`에 어떤 참조값을 기록할지 결정해야 했다.
ADR-0002에서 lock 파일을 사용하는 정책(수동 업데이트)을 결정했고,
이 ADR은 그 lock 파일의 참조 타입(semver 태그 vs commit SHA)을 결정한다.

## 결정

**semver 태그 대신 commit SHA를 `skills-lock.json`의 `ref` 필드에 기록한다.**

```json
{
  "installedAt": "2026-03-17T00:00:00Z",
  "source": "github:kyeongsoo-yoo/agent-foundry",
  "ref": "abc1234def5678",
  "template": "fullstack",
  "skills": ["coding-conventions"]
}
```

## 근거

**SHA의 불변성:**
- Git 태그는 `git push --force`로 다른 커밋을 가리키도록 변경 가능
- commit SHA는 내용 기반 해시로 변경 불가능
- lock 파일의 목적(재현성)에 SHA가 더 적합

**단순성:**
- semver 태그 관리(태깅 규율, CHANGELOG 유지)가 불필요
- SHA는 `git rev-parse HEAD`로 자동 획득 가능

## 결과

- `skills-lock.json`의 `ref` 필드는 항상 full commit SHA
- `bin/agent-foundry.js`는 설치 시 현재 HEAD SHA를 `ref`에 기록
- `update-skills.sh` 실행 시 새 SHA로 `ref` 업데이트

## ADR-0002와의 관계

ADR-0002: 설치 후 자동 업데이트 없음, 수동 `update-skills.sh`로만 업데이트
ADR-0004: 그 lock 파일에 기록하는 참조 타입은 commit SHA
