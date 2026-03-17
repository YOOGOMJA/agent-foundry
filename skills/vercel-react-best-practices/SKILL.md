---
name: vercel-react-best-practices
description: React/Next.js 성능 최적화 패턴 적용 시 참조. Server/Client Component 분리, RSC data fetching, 번들 최적화 등을 다룬다.
---

# Vercel React Best Practices

> **이 스킬은 외부 스킬의 thin adapter입니다.** 상세 가이드는 아래 외부 스킬을 설치해 사용하세요.

## 외부 스킬 설치

```bash
npx skills add https://github.com/vercel-labs/agent-skills --skill react-best-practices
```

## 핵심 원칙 요약

1. **Server/Client Component 분리**: 데이터 페칭과 상태관리 로직은 Server Component에서. 인터랙션은 `'use client'`로 분리.
2. **RSC data fetching**: `fetch`에 `cache`, `next.revalidate` 옵션 활용. `unstable_cache`로 데이터 레이어 캐싱.
3. **번들 최적화**: `dynamic import`로 클라이언트 번들 분할. `next/image`, `next/font`로 정적 에셋 최적화.
4. **Route Handler 캐싱**: API Route는 `export const dynamic = 'force-dynamic'` 또는 기본 캐시 동작 명시.

자세한 패턴, 예시, 안티패턴은 외부 스킬 설치 후 참고.
