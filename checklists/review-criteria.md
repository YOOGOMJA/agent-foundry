# Review Criteria — Phase별 Ralph Loop 검증 기준

Ralph Loop에서 "CONVERGED"를 쓰려면 아래 기준을 **기계적으로** 모두 통과해야 한다.
주관적 판단("충분히 좋다")은 수렴 근거로 인정하지 않는다.

---

## Phase 1: 요구사항

### docs/prd.md
- [ ] 모든 FR에 최소 1개 AC가 있다
- [ ] Open Questions 섹션이 비어있다 (0개)
- [ ] Success Metrics가 최소 1개 있고 측정 가능하다
- [ ] Out of Scope이 명시되어 있다

### docs/user-stories.md
- [ ] 모든 스토리가 "As a {user}, I want {goal}, so that {benefit}" 형식이다
- [ ] 각 스토리에 AC가 있다

### docs/screen-spec.md
- [ ] 모든 화면에 Route가 명시되어 있다
- [ ] 모든 화면에 Components 목록이 있다
- [ ] 모든 Data Sources에 API 엔드포인트 또는 상태 소스가 명시되어 있다
- [ ] 모든 화면에 AC가 있다

---

## Phase 2A: 기술 설계

### docs/architecture.md
- [ ] FSD 레이어별 슬라이스가 나열되어 있다
- [ ] NestJS 모듈 목록이 있다
- [ ] packages/types 구조가 정의되어 있다
- [ ] ADR Index에 모든 결정이 등록되어 있다

### docs/api-spec.md
- [ ] 모든 screen-spec의 Data Sources API가 대응하는 엔드포인트를 갖는다
- [ ] 모든 엔드포인트에 Request/Response 타입이 있다
- [ ] packages/types/ 경로가 명시되어 있다

### docs/db-schema.md
- [ ] 모든 엔티티 타입에 대응하는 테이블/컬렉션이 있다
- [ ] 관계(1:N, N:M)가 명시되어 있다

---

## Phase 2B: 디자인 시스템

### packages/ui/
- [ ] 디자인 토큰이 정의되어 있다 (colors, typography, spacing 최소)
- [ ] screen-spec에서 참조하는 모든 컴포넌트가 구현되어 있다
- [ ] 각 컴포넌트에 .stories.tsx 파일이 있다
- [ ] Storybook이 에러 없이 빌드된다 (`npm run build-storybook`)
- [ ] WCAG 2.1 AA: 색상 대비 4.5:1 이상
- [ ] VRT 최초 베이스라인 생성 완료 (`npx playwright test --update-snapshots`)

---

## Phase 2C: 구현 계획

> Phase 2 게이트에 포함. 별도 인간 승인 없음.

### docs/plan.md
- [ ] 모든 FSD 슬라이스에 대해 구현 태스크가 나열되어 있다
- [ ] 각 태스크에 대상 파일 경로가 명시되어 있다
- [ ] BE 모듈별 태스크가 포함되어 있다

### docs/plan-slices.txt
- [ ] 파일이 존재하고 한 줄에 하나의 슬라이스 이름이 있다
- [ ] 슬라이스 이름이 docs/architecture.md의 features/ 목록과 일치한다

---

## Phase 3: 구현

### apps/web
- [ ] `npm run build --workspace=apps/web` 성공
- [ ] `npm run lint --workspace=apps/web` 에러 0 (경고는 허용)
- [ ] 모든 feature 슬라이스에 최소 1개 테스트 파일이 있다
- [ ] `npm run test --workspace=apps/web` 전체 통과
- [ ] steiger 실행 완료 (비차단, 결과 기록)

### apps/api
- [ ] `npm run build --workspace=apps/api` 성공
- [ ] `npm run lint --workspace=apps/api` 에러 0
- [ ] 모든 엔드포인트에 최소 1개 테스트가 있다
- [ ] `npm run test --workspace=apps/api` 전체 통과

### packages/types
- [ ] `tsc --noEmit` 성공 (타입 에러 0)

---

## Phase 4: 테스트

### VRT
- [ ] `npx playwright test --grep @vrt` 전체 통과
- [ ] 새 스크린샷이 있으면 베이스라인 업데이트 포함

### E2E
- [ ] `npx playwright test --grep @e2e` 전체 통과
- [ ] Critical flow (로그인, 핵심 CRUD) 포함

### 비차단 (리포트만)
- [ ] Lost Pixel 실행 완료 (결과 docs/test-report.md에 기록)
- [ ] steiger 실행 완료 (결과 docs/test-report.md에 기록)

### docs/test-report.md
- [ ] 모든 축의 결과가 기록되어 있다
- [ ] PASSED 또는 FAILED가 명시되어 있다
- [ ] 실패 시 실패 상세가 포함되어 있다

---

## Phase 5A: Critic 모드 (Ralph Loop 5회차)

Critic은 이전 반복의 작업자와 독립적 관점에서 검증한다.

### 검증 항목
- [ ] docs/prd.md의 Acceptance Criteria가 구현에서 모두 충족되는가
- [ ] 엣지 케이스가 처리되었는가 (빈 배열, null, 경계값)
- [ ] API 에러 코드(400, 401, 404, 500)가 프론트에서 핸들링되는가
- [ ] XSS, injection 등 보안 위험이 없는가
- [ ] N+1 쿼리, 불필요한 리렌더링 등 성능 문제가 없는가
- [ ] FSD public API 위반이 없는가 (index.ts 우회 import)
- [ ] packages/types와 실제 API 응답이 일치하는가

### 통과 조건
위 항목 모두 통과 시에만 CONVERGED. 1개라도 위반 시 이전 반복으로 되돌림.

---

## Phase 5B: 인간 리뷰 (PR)

### PR 본문 검증
- [ ] 변경 요약이 1-2 문단으로 존재한다
- [ ] 의도 ("FR-XXX 구현")가 명시되어 있다
- [ ] Layer 1-4 자동 검증 통과 증거가 있다
- [ ] Critic 리뷰 결과가 포함되어 있다
- [ ] 리스크 분석이 "없음" 또는 구체적 내용으로 존재한다
