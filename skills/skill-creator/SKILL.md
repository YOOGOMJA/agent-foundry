---
name: skill-creator
description: agent-foundry에 새 스킬을 추가하거나 기존 스킬을 수정할 때 사용. 스킬 디렉토리 구조, frontmatter 형식, references/ 분리 기준, manifests 등록 절차를 안내.
---

# Skill Creator

agent-foundry에 새 스킬을 추가하거나 기존 스킬을 수정할 때 이 스킬을 먼저 로드한다.

> **이 스킬은 배포용 스킬이 아닙니다.** agent-foundry 레포 기여자(사람 또는 AI)가 스킬 작성 시 참조하는 메타 가이드입니다. `manifests/skills.json`에 등록하지 않습니다.

---

## 스킬 디렉토리 구조

```
skills/<skill-name>/
  SKILL.md          # 필수. 스킬 본문 + frontmatter
  references/       # 선택. 상세 참고 문서 (SKILL.md가 길어질 때 분리)
  scripts/          # 선택. 스킬이 참조하는 스크립트
  assets/           # 선택. 이미지, 예시 파일 등
```

---

## frontmatter 형식

모든 SKILL.md는 YAML frontmatter로 시작해야 한다:

```yaml
---
name: <skill-name>         # 필수. manifests/skills.json의 키와 일치
description: <한 줄 설명>   # 필수. 언제 이 스킬을 사용하는지 명확하게
---
```

**description 작성 원칙:**
- "언제 이 스킬이 활성화되는가"를 포함할 것
- 예시: `TypeScript/React 프로젝트의 코드를 작성, 수정, 리뷰할 때 자동 적용`
- 단순한 기능 나열보다 트리거 조건을 명확히

---

## SKILL.md 작성 원칙

1. **트리거 조건 명시**: 어떤 상황에서 이 스킬이 로드/적용되는가
2. **규칙 목록**: AI가 따라야 할 구체적인 규칙. 모호한 표현 금지
3. **예시 포함**: Good/Bad 예시가 있으면 훨씬 효과적
4. **YAGNI**: 지금 필요한 규칙만. 미래 확장성을 위한 규칙 금지
5. **길이 기준**: 500자 초과 상세 내용은 `references/`로 분리

---

## references/ 분리 기준

SKILL.md 본문이 길어지면 `references/`로 분리:

- **분리해야 할 것**: 패턴 예시, 상세 코드 스니펫, 도구별 설정 예시
- **본문에 유지할 것**: 핵심 규칙, 트리거 조건, references 링크

링크 형식:
```markdown
상세 패턴: [references/naming.md](references/naming.md)
```

---

## 완료 체크리스트

새 스킬 추가 시 아래를 순서대로 완료해야 한다:

- [ ] `skills/<skill-name>/SKILL.md` 작성 (frontmatter 포함)
- [ ] `manifests/skills.json`에 등록:
  ```json
  "<skill-name>": {
    "path": "skills/<skill-name>",
    "description": "<한 줄 설명>"
  }
  ```
- [ ] smoke test 통과: `bash tests/smoke/run-all.sh`
- [ ] 커밋 및 PR 생성

---

## 예시: 최소 스킬 구조

디렉토리:
```
skills/my-skill/
  SKILL.md
```

SKILL.md 내용 (frontmatter):
```yaml
---
name: my-skill
description: React 컴포넌트를 작성할 때 적용. 접근성 규칙과 성능 패턴을 강제.
---
```

SKILL.md 내용 (본문):
```markdown
# My Skill

## 적용 조건
React 컴포넌트(.tsx)를 작성하거나 수정할 때.

## 규칙
1. 모든 이미지에 alt 텍스트 필수
2. 이벤트 핸들러는 `handle` 접두사 사용
```

manifests/skills.json 등록:
```json
{
  "my-skill": {
    "path": "skills/my-skill",
    "description": "React 컴포넌트 접근성 및 성능 패턴"
  }
}
```
