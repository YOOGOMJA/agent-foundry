# FP Patterns — 순수 함수 분리 & 불변성

## 원칙

1. 비즈니스 로직 = 순수 함수 (입력 → 출력, side effect 없음)
2. side effect(API 호출, DOM 조작, store 변경)는 경계에서만
3. const + spread/map/filter로 불변성 유지

## 순수 함수 분리

```typescript
// Bad: 로직과 side effect가 섞임
const handleSubmit = async (form: FormData) => {
  let total = 0
  for (const item of form.items) {
    if (item.isActive) {
      total += item.price * item.quantity
    }
  }
  const tax = total * 0.1
  await api.createOrder({ total: total + tax })
  store.setOrderComplete(true)
}

// Good: 계산을 순수 함수로 분리
const calculateItemTotal = (items: Item[]): number =>
  items
    .filter(item => item.isActive)
    .reduce((sum, item) => sum + item.price * item.quantity, 0)

const calculateTotalWithTax = (subtotal: number, taxRate: number): number =>
  subtotal + subtotal * taxRate

// 경계: side effect만 담당
const handleSubmit = async (form: FormData) => {
  const subtotal = calculateItemTotal(form.items)
  const total = calculateTotalWithTax(subtotal, 0.1)
  await api.createOrder({ total })
  store.setOrderComplete(true)
}
```

## 불변성

```typescript
// Bad: 직접 변경
const updateUser = (user: User) => {
  user.name = 'new name'       // mutation
  user.roles.push('admin')     // mutation
  return user
}

// Good: 새 객체 반환
const updateUserName = (user: User, name: string): User => ({
  ...user,
  name,
})

const addUserRole = (user: User, role: string): User => ({
  ...user,
  roles: [...user.roles, role],
})
```

## 배열 변환

```typescript
// Bad: for loop + push
const getActiveNames = (users: User[]) => {
  const result: string[] = []
  for (const user of users) {
    if (user.isActive) {
      result.push(user.name)
    }
  }
  return result
}

// Good: 선언적 체이닝
const getActiveNames = (users: User[]): string[] =>
  users
    .filter(user => user.isActive)
    .map(user => user.name)
```

## 조건부 로직

```typescript
// Bad: 중첩 if + mutation
const getDiscount = (user: User, cart: Cart) => {
  let discount = 0
  if (user.isPremium) {
    discount = 0.1
    if (cart.total > 100) {
      discount = 0.2
    }
  }
  return discount
}

// Good: 패턴 매칭 스타일
const getDiscountRate = (isPremium: boolean, cartTotal: number): number => {
  if (!isPremium) return 0
  if (cartTotal > 100) return 0.2
  return 0.1
}
```
