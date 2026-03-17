# Architecture

## FSD Structure (apps/web)

### Layers
- app/: providers, routing, global styles
- pages/: route-level compositions
- widgets/: page sections
- features/: user interactions
- entities/: business entities
- shared/: packages/ui re-export, utilities

### Slices
<!-- Phase 2C에서 docs/plan-slices.txt로 추출됨 -->
- features/{slice-name}/

## NestJS Structure (apps/api)

### Modules
- auth/: authentication, authorization
- {domain}/: {description}

## Shared Types (packages/types)

- api/: Request/Response DTOs
- domain/: business entity types
- config/: shared configuration types

## State Management
<!-- ADR로 결정: Zustand? TanStack Query? Server Components? -->

## Data Fetching Pattern
<!-- ADR로 결정: REST? tRPC? Server Actions? -->

## ADR Index
- ADR-001: {title} — {status}
