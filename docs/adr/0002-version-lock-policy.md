# ADR-0002: 버전 고정 및 업데이트 정책

- 상태: Accepted
- 날짜: 2026-03-16

## 문맥
설치 시점마다 결과가 달라지면 재현성과 디버깅이 어려워진다.

## 결정
고정 버전 + `skills-lock.json` + 수동 업데이트 정책을 채택한다.

## 근거
- 동일 lock으로 재설치 시 동일 결과 보장
- 의도하지 않은 자동 업그레이드 방지
- 변경 시점과 영향 추적 용이

## 결과
- `scripts/bootstrap-project.sh`가 lock 파일 생성
- `scripts/update-skills.sh`는 lock 기준으로만 업데이트 수행
