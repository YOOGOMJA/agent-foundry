---
name: coding-conventions
description: TypeScript/React 프로젝트의 코딩 컨벤션 강제. 코드를 작성, 수정, 리뷰할 때 자동 적용. 대상: (1) Clean Code 명명 규칙, (2) Functional Programming 패턴 (순수 함수 분리, 불변성), (3) FSD public API 및 슬라이스 구조, (4) Zustand/XState 상태관리 패턴, (5) SOLID/DRY/YAGNI 원칙 적용.
---

# Coding Conventions

## 핵심 원칙

1. **FP 우선**: 비즈니스 로직은 순수 함수로 분리. side effect는 경계(store, API, event handler)에서만.
2. **불변성**: const + 불변 데이터 구조. 배열/객체 변경 시 spread 또는 구조적 공유.
3. **FSD public API**: 슬라이스 외부에서는 반드시 index.ts를 통해서만 import.
4. **YAGNI**: 현재 요구사항에 없는 기능, 추상화, 설정 가능성 금지.
5. **DRY**: 3회 이상 반복 시에만 추출. 2회 반복은 허용 (premature abstraction 방지).

## 명명 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 변수, 함수 | camelCase | `getUserName`, `isActive` |
| 타입, 인터페이스, 컴포넌트 | PascalCase | `UserProfile`, `AuthStore` |
| 상수 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| 파일 (컴포넌트) | PascalCase.tsx | `UserProfile.tsx` |
| 파일 (유틸/모델) | camelCase.ts | `calculateTotal.ts` |
| 디렉토리 | kebab-case | `user-profile/`, `auth-form/` |
| boolean | is/has/can/should 접두사 | `isLoading`, `hasPermission` |
| 이벤트 핸들러 | handle + 동사 | `handleSubmit`, `handleClick` |
| 순수 함수 | 동사 + 명사 (행위 설명) | `calculateDiscount`, `filterActiveUsers` |

상세 예시: [references/naming.md](references/naming.md)

## 패턴 가이드

코드 작성 시 해당 영역의 reference를 참조:

- **순수 함수 분리, 불변성 패턴** → [references/fp-patterns.md](references/fp-patterns.md)
- **FSD 슬라이스 구조, public API, import 규칙** → [references/fsd-public-api.md](references/fsd-public-api.md)
- **Zustand 슬라이스, 순수 함수 상태 변환** → [references/zustand-patterns.md](references/zustand-patterns.md)
- **XState 액터 모델, Zustand과 판단 기준** → [references/xstate-patterns.md](references/xstate-patterns.md)

## SOLID 적용 기준

- **SRP**: 함수는 하나의 일만. 파일은 하나의 관심사만. 200줄 초과 시 분리 검토.
- **OCP**: 확장에 열려있고 수정에 닫혀야 함. 조건 분기보다 컴포지션/전략 패턴.
- **LSP**: 인터페이스 구현 시 계약 준수. 타입 좁히기(discriminated union) 활용.
- **ISP**: 인터페이스는 작게. 거대한 Props 타입보다 조합 가능한 작은 타입.
- **DIP**: 구체 의존보다 인터페이스/타입 의존. FSD shared 레이어를 통한 의존성 역전.
