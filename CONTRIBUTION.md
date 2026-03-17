# 기여 가이드

## 기본 흐름

```
Issue -> Plan -> Branch/Worktree -> Commit -> PR
```

## 브랜치 네이밍

```
feat/<topic>      # 새 기능 (스킬 추가, CLI 기능 등)
fix/<topic>       # 버그 수정
docs/<topic>      # 문서만 변경
chore/<topic>     # 빌드, 설정, 정리
```

예시: `feat/skill-creator`, `docs/agents-md-update`

## 커밋 컨벤션

conventional commits 형식:

```
feat: skill-creator 스킬 추가
fix: bootstrap-project.sh 경로 오류 수정
docs: AGENTS.md 운영 규칙 상세화
chore: manifests/skills.json coding-conventions 등록
```

## 스킬 기여 프로세스

새 스킬을 추가할 때:

1. `skills/skill-creator/SKILL.md` 읽기
2. `skills/<skill-name>/SKILL.md` 작성 (frontmatter 필수)
3. `manifests/skills.json`에 등록
4. smoke test 통과 확인: `bash tests/smoke/run-all.sh`
5. PR 생성 (smoke test 통과 증거 포함)

## PR 요건

- [ ] smoke test 전체 통과: `bash tests/smoke/run-all.sh`
- [ ] 새 스킬이라면 `manifests/skills.json` 등록 포함
- [ ] 아키텍처 변경이라면 ADR 포함 (`docs/adr/NNNN-<topic>.md`)
- [ ] PR 본문에 변경 내용 요약 포함

## ADR 작성 기준

다음 경우 ADR 작성:
- 새 스킬 배포 방식 변경
- CLI 플래그 추가/변경
- manifests 구조 변경
- 외부 의존성 추가

자동 진행 가능 (ADR 불필요):
- 스킬 내용 수정
- 문서 업데이트
- 단일 파일 버그 수정
