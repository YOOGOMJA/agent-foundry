# API Specification

## Endpoint: {METHOD} /api/{path}

- **Module**: {NestJS 모듈명}
- **Auth**: {required | optional | none}
- **Request**:
  ```typescript
  // packages/types/src/api/{module}.ts
  interface RequestDTO { }
  ```
- **Response**:
  ```typescript
  interface ResponseDTO { }
  ```
- **Error Codes**:
  - 400: Bad Request — {조건}
  - 401: Unauthorized
  - 404: Not Found
  - 500: Internal Server Error
- **Referenced ADR**: ADR-{NNN}
