# Zustand Patterns — FSD + FP

## 원칙

1. 상태 변환 로직은 **순수 함수**로 분리 (model/calculations.ts)
2. store는 순수 함수를 **호출만** 함 (model/store.ts)
3. FSD 슬라이스별로 독립 store 또는 슬라이스 패턴

## 기본 패턴: 순수 함수 분리

```typescript
// features/cart/model/calculations.ts — 순수 함수
export const addItemToCart = (items: CartItem[], newItem: CartItem): CartItem[] => {
  const existing = items.find(item => item.id === newItem.id)
  if (existing) {
    return items.map(item =>
      item.id === newItem.id
        ? { ...item, quantity: item.quantity + newItem.quantity }
        : item
    )
  }
  return [...items, newItem]
}

export const calculateCartTotal = (items: CartItem[]): number =>
  items.reduce((sum, item) => sum + item.price * item.quantity, 0)

export const canCheckout = (items: CartItem[]): boolean =>
  items.length > 0 && items.every(item => item.quantity > 0)
```

```typescript
// features/cart/model/store.ts — store는 순수 함수 호출만
import { create } from 'zustand'
import { addItemToCart, calculateCartTotal } from './calculations'

interface CartStore {
  items: CartItem[]
  addItem: (item: CartItem) => void
  removeItem: (id: string) => void
  readonly total: number
}

export const useCartStore = create<CartStore>((set, get) => ({
  items: [],
  addItem: (item) => set(state => ({
    items: addItemToCart(state.items, item),
  })),
  removeItem: (id) => set(state => ({
    items: state.items.filter(item => item.id !== id),
  })),
  get total() {
    return calculateCartTotal(get().items)
  },
}))
```

## 슬라이스 패턴 (복수 도메인 공유 시)

```typescript
// entities/session/model/store.ts
import { StateCreator } from 'zustand'

export interface SessionSlice {
  user: User | null
  isAuthenticated: boolean
  setUser: (user: User | null) => void
}

export const createSessionSlice: StateCreator<SessionSlice> = (set) => ({
  user: null,
  isAuthenticated: false,
  setUser: (user) => set({
    user,
    isAuthenticated: user !== null,
  }),
})
```

## Bad Patterns

```typescript
// Bad: store 안에 비즈니스 로직 인라인
export const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set(state => {
    // 이 로직이 store 안에 있으면 테스트/재사용 어려움
    const existing = state.items.find(i => i.id === item.id)
    if (existing) {
      return { items: state.items.map(i => i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i) }
    }
    return { items: [...state.items, item] }
  }),
}))

// Bad: 컴포넌트에서 store 내부 구조에 의존
const CartTotal = () => {
  const items = useCartStore(state => state.items)
  // 컴포넌트가 계산 로직을 가짐
  const total = items.reduce((s, i) => s + i.price * i.quantity, 0)
  return <span>{total}</span>
}

// Good: store가 computed value 제공
const CartTotal = () => {
  const total = useCartStore(state => state.total)
  return <span>{total}</span>
}
```
