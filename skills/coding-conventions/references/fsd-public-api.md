# FSD Public API & 슬라이스 구조

## 슬라이스 디렉토리 구조

```
features/auth/
├── index.ts              ← public API (유일한 외부 접근점)
├── ui/
│   ├── LoginForm.tsx
│   └── LogoutButton.tsx
├── model/
│   ├── store.ts          ← Zustand 슬라이스
│   ├── calculations.ts   ← 순수 함수 (비즈니스 로직)
│   └── types.ts
├── api/
│   └── authApi.ts
└── lib/
    └── tokenUtils.ts
```

## Public API (index.ts)

```typescript
// features/auth/index.ts

// UI
export { LoginForm } from './ui/LoginForm'
export { LogoutButton } from './ui/LogoutButton'

// Model (store + types만 공개, 내부 계산 함수는 비공개)
export { useAuthStore } from './model/store'
export type { AuthState, LoginCredentials } from './model/types'
```

## Import 규칙

```typescript
// Bad: 내부 모듈 직접 import (public API 우회)
import { LoginForm } from '@/features/auth/ui/LoginForm'
import { tokenUtils } from '@/features/auth/lib/tokenUtils'

// Good: public API를 통해서만
import { LoginForm, useAuthStore } from '@/features/auth'

// Bad: features 간 직접 import
import { useCartStore } from '@/features/cart/model/store'

// Good: features 간은 shared를 통하거나 각자의 public API
import { useCartStore } from '@/features/cart'
```

## 레이어 간 import 규칙

```typescript
// features/ → entities/, shared/ 만 가능
// features/ → features/ 금지 (cross-import)
// features/ → widgets/, pages/, app/ 금지 (상위 레이어)

// Good: feature → entity
import { UserCard } from '@/entities/user'

// Good: feature → shared
import { Button } from '@/shared/ui'

// Bad: feature → feature
import { useAuthStore } from '@/features/auth'  // dashboard에서 auth 직접 참조
// → 대신 entities/session 같은 공유 레이어로 추출
```
