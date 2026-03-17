# XState Patterns — 언제 쓰고, 어떻게 구조화하나

## Zustand vs XState 판단 기준

| 상황 | Zustand | XState |
|------|---------|--------|
| 단순 토글/플래그 | ✓ | |
| CRUD 상태 (loading/error/data) | ✓ | |
| 폼 입력 상태 | ✓ | |
| **멀티스텝 폼/위자드** | | ✓ |
| **복잡한 비동기 시퀀스** (결제 플로우) | | ✓ |
| **상태 전이 규칙이 엄격한 경우** (주문 상태) | | ✓ |
| **병렬 상태** (동시에 여러 독립 상태) | | ✓ |
| **타이머/지연 기반 로직** | | ✓ |

**경험 법칙**: "if/else로 상태 전이를 관리하다 복잡해지면" XState로 전환.

## FSD 배치

```
features/checkout/
├── index.ts
├── model/
│   ├── machine.ts            ← XState 머신 정의
│   ├── actions.ts            ← 머신 액션 (순수 함수)
│   ├── guards.ts             ← 머신 가드 (순수 함수)
│   └── types.ts              ← 컨텍스트/이벤트 타입
├── ui/
│   └── CheckoutWizard.tsx    ← useMachine() 사용
└── api/
    └── paymentApi.ts
```

## 기본 패턴 (v5)

```typescript
// features/checkout/model/types.ts
interface CheckoutContext {
  items: CartItem[]
  shippingAddress: Address | null
  paymentMethod: PaymentMethod | null
  error: string | null
}

type CheckoutEvent =
  | { type: 'SET_ADDRESS'; address: Address }
  | { type: 'SET_PAYMENT'; method: PaymentMethod }
  | { type: 'CONFIRM' }
  | { type: 'BACK' }

// features/checkout/model/guards.ts — 순수 함수
export const hasAddress = (context: CheckoutContext): boolean =>
  context.shippingAddress !== null

export const hasPayment = (context: CheckoutContext): boolean =>
  context.paymentMethod !== null

// features/checkout/model/machine.ts
import { setup, assign } from 'xstate'
import { hasAddress, hasPayment } from './guards'

export const checkoutMachine = setup({
  types: {
    context: {} as CheckoutContext,
    events: {} as CheckoutEvent,
  },
  guards: { hasAddress, hasPayment },
}).createMachine({
  id: 'checkout',
  initial: 'shipping',
  context: { items: [], shippingAddress: null, paymentMethod: null, error: null },
  states: {
    shipping: {
      on: {
        SET_ADDRESS: {
          actions: assign({ shippingAddress: ({ event }) => event.address }),
        },
        CONFIRM: { target: 'payment', guard: 'hasAddress' },
      },
    },
    payment: {
      on: {
        SET_PAYMENT: {
          actions: assign({ paymentMethod: ({ event }) => event.method }),
        },
        CONFIRM: { target: 'review', guard: 'hasPayment' },
        BACK: { target: 'shipping' },
      },
    },
    review: {
      on: {
        CONFIRM: { target: 'processing' },
        BACK: { target: 'payment' },
      },
    },
    processing: {
      invoke: {
        src: 'processPayment',
        onDone: { target: 'complete' },
        onError: {
          target: 'review',
          actions: assign({ error: ({ event }) => event.error.message }),
        },
      },
    },
    complete: { type: 'final' },
  },
})
```

## 컴포넌트 연결

```typescript
// features/checkout/ui/CheckoutWizard.tsx
import { useMachine } from '@xstate/react'
import { checkoutMachine } from '../model/machine'

export const CheckoutWizard = () => {
  const [state, send] = useMachine(checkoutMachine)

  // 상태에 따라 렌더링
  if (state.matches('shipping')) return <ShippingForm onSubmit={...} />
  if (state.matches('payment')) return <PaymentForm onSubmit={...} />
  if (state.matches('review')) return <ReviewStep onConfirm={...} />
  if (state.matches('processing')) return <LoadingSpinner />
  if (state.matches('complete')) return <SuccessMessage />
}
```
