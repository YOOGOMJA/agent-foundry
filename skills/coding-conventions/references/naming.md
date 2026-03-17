# Naming Conventions — Good/Bad Examples

## 변수

```typescript
// Bad
const d = new Date()
const u = fetchUser()
const flag = true

// Good
const createdAt = new Date()
const currentUser = fetchUser()
const isVerified = true
```

## 함수 (순수 함수)

```typescript
// Bad: 모호한 이름, 무엇을 계산하는지 불명확
const process = (items: Item[]) => items.filter(i => i.active)

// Good: 행위를 명확히 설명
const filterActiveItems = (items: Item[]) => items.filter(item => item.isActive)
```

## 함수 (이벤트 핸들러)

```typescript
// Bad
const submit = () => { ... }
const click = () => { ... }

// Good
const handleFormSubmit = () => { ... }
const handleDeleteClick = () => { ... }
```

## 타입/인터페이스

```typescript
// Bad
interface data { ... }
type response = { ... }

// Good
interface UserProfile { ... }
type LoginResponse = { ... }
```

## 상수

```typescript
// Bad
const maxRetry = 3
const baseUrl = '/api'

// Good
const MAX_RETRY_COUNT = 3
const API_BASE_URL = '/api'
```

## Boolean

```typescript
// Bad
const loading = true
const admin = false
const valid = true

// Good
const isLoading = true
const hasAdminRole = false
const canSubmitForm = true
```

## 파일/디렉토리

```
Bad:
  userprofile.tsx
  Utils.ts
  AuthForm/

Good:
  UserProfile.tsx        (컴포넌트: PascalCase)
  calculateTotal.ts      (유틸/모델: camelCase)
  auth-form/             (디렉토리: kebab-case)
```
