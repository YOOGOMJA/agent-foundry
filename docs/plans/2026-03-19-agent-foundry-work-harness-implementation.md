# Agent Foundry Work Harness Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `agent-foundry`를 `skills search/install + audit + docs suggest/write` 중심의 개인 작업 하네스로 구현하고, curated+external 하이브리드 설치를 lock 기반으로 재현 가능하게 만든다.

**Architecture:** `bin/agent-foundry.js`는 서브커맨드 라우팅만 담당하고, 기능은 `lib/` 모듈(`catalog`, `installer`, `auditor`, `doc-writer`, `prompt`)로 분리한다. 설치는 adapter(`local-copy`, `git-copy`)로 분기하며, `skills-lock.json` v2 스키마를 기본으로 사용하고 v1 입력은 자동 마이그레이션한다. 회귀 방지는 `tests/smoke/*`를 확장해 README 예시, manifest 정합성, lock 정책, 외부 설치, audit/docs 흐름까지 커버한다.

**Tech Stack:** Node.js 18+ (built-in `fs`, `path`, `child_process`, `readline`), Bash, jq, git, existing smoke test harness

---

### Task 1: Catalog 단일 소스 도입

**Files:**
- Create: `manifests/catalog.json`
- Create: `tests/smoke/manifest/02-catalog-shape.sh`
- Modify: `tests/smoke/run-all.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

[[ -f "$ROOT/manifests/catalog.json" ]] || { echo "missing catalog.json"; exit 1; }
jq -e '
  has("skills") and .skills|type=="array" and (.skills|length>0) and
  has("docs") and .docs|type=="array" and
  (.skills[0] | has("name") and has("description") and has("install") and has("trust"))
' "$ROOT/manifests/catalog.json" >/dev/null
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/manifest/02-catalog-shape.sh`  
Expected: FAIL with `missing catalog.json`

**Step 3: Write minimal implementation**

```json
{
  "skills": [
    {
      "name": "coding-conventions",
      "description": "TypeScript/React 코드 컨벤션",
      "trust": "curated",
      "install": { "kind": "local-copy", "path": "skills/coding-conventions" }
    }
  ],
  "docs": [
    {
      "type": "goal",
      "source": "templates/handoff/goal.md",
      "destination": "docs/goal.md"
    }
  ]
}
```

**Step 4: Run test to verify it passes**

Run: `bash tests/smoke/manifest/02-catalog-shape.sh`  
Expected: PASS (exit code 0)

**Step 5: Commit**

```bash
git add manifests/catalog.json tests/smoke/manifest/02-catalog-shape.sh tests/smoke/run-all.sh
git commit -m "feat: add unified catalog manifest and schema smoke test"
```

### Task 2: CLI 서브커맨드 라우팅 골격

**Files:**
- Create: `lib/cli.js`
- Modify: `bin/agent-foundry.js`
- Create: `tests/smoke/scripts/04-cli-subcommands.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

node "$ROOT/bin/agent-foundry.js" skills search >/dev/null
node "$ROOT/bin/agent-foundry.js" audit --format json >/dev/null
node "$ROOT/bin/agent-foundry.js" docs suggest >/dev/null
if node "$ROOT/bin/agent-foundry.js" nope 2>/dev/null; then
  echo "expected unknown command to fail"; exit 1
fi
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/scripts/04-cli-subcommands.sh`  
Expected: FAIL (`Error: --template or --skills is required` or unknown command behavior missing)

**Step 3: Write minimal implementation**

```js
// lib/cli.js
function dispatch(argv) {
  const [group, command] = argv;
  if (group === 'skills' && command === 'search') return { ok: true };
  if (group === 'skills' && command === 'install') return { ok: true };
  if (group === 'audit') return { ok: true };
  if (group === 'docs' && (command === 'suggest' || command === 'write')) return { ok: true };
  throw new Error(`Unknown command: ${argv.join(' ')}`);
}
module.exports = { dispatch };
```

**Step 4: Run test to verify it passes**

Run: `bash tests/smoke/scripts/04-cli-subcommands.sh`  
Expected: PASS

**Step 5: Commit**

```bash
git add lib/cli.js bin/agent-foundry.js tests/smoke/scripts/04-cli-subcommands.sh
git commit -m "feat: add CLI subcommand routing skeleton"
```

### Task 3: `skills search` 구현 (curated/all)

**Files:**
- Create: `lib/catalog.js`
- Modify: `lib/cli.js`
- Create: `tests/smoke/scripts/05-skills-search.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

OUT=$(node "$ROOT/bin/agent-foundry.js" skills search coding --source curated)
echo "$OUT" | grep -q "coding-conventions"
echo "$OUT" | grep -q "curated"
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/scripts/05-skills-search.sh`  
Expected: FAIL (search output not implemented)

**Step 3: Write minimal implementation**

```js
// lib/catalog.js
function searchSkills({ query = '', source = 'curated', catalog }) {
  const q = query.toLowerCase();
  return catalog.skills
    .filter((s) => (source === 'all' ? true : s.trust === source))
    .filter((s) => !q || s.name.includes(q) || s.description.toLowerCase().includes(q));
}
```

**Step 4: Run test to verify it passes**

Run: `bash tests/smoke/scripts/05-skills-search.sh`  
Expected: PASS, output contains `coding-conventions`

**Step 5: Commit**

```bash
git add lib/catalog.js lib/cli.js tests/smoke/scripts/05-skills-search.sh
git commit -m "feat: implement curated skills search from catalog"
```

### Task 4: `skills install` curated + lock v2

**Files:**
- Create: `lib/installer.js`
- Modify: `lib/cli.js`
- Modify: `scripts/update-skills.sh`
- Create: `tests/smoke/scripts/06-skills-install-lock-v2.sh`
- Create: `tests/smoke/scripts/07-update-lock-migration.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

(
  cd "$TMP"
  node "$ROOT/bin/agent-foundry.js" skills install coding-conventions
)

[[ -f "$TMP/.agents/skills/coding-conventions/SKILL.md" ]]
jq -e '.schemaVersion == 2 and (.skills|length)==1 and has("externals")' "$TMP/skills-lock.json" >/dev/null
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/scripts/06-skills-install-lock-v2.sh`  
Expected: FAIL (lock v2 fields missing)

**Step 3: Write minimal implementation**

```js
// lib/installer.js
function writeLockV2({ targetDir, skills, externals }) {
  const lock = {
    schemaVersion: 2,
    installedAt: new Date().toISOString(),
    source: 'github:kyeongsoo-yoo/agent-foundry',
    ref: resolveGitHeadOrLocal(),
    template: null,
    skills,
    externals
  };
  fs.writeFileSync(path.join(targetDir, 'skills-lock.json'), JSON.stringify(lock, null, 2));
}
```

**Step 4: Run test to verify it passes**

Run:
1. `bash tests/smoke/scripts/06-skills-install-lock-v2.sh`
2. `bash tests/smoke/scripts/07-update-lock-migration.sh`  
Expected: PASS, v1 lock input이 v2로 재기록됨

**Step 5: Commit**

```bash
git add lib/installer.js lib/cli.js scripts/update-skills.sh tests/smoke/scripts/06-skills-install-lock-v2.sh tests/smoke/scripts/07-update-lock-migration.sh
git commit -m "feat: add curated install and lock v2 migration"
```

### Task 5: external 설치(`git-copy`) + 동의 플래그

**Files:**
- Modify: `lib/installer.js`
- Create: `tests/fixtures/external-skills-repo/skills/external-audit/SKILL.md`
- Create: `tests/smoke/scripts/08-external-install.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
FIXTURE="$ROOT/tests/fixtures/external-skills-repo"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if (cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install "$FIXTURE" --skill external-audit 2>/dev/null); then
  echo "expected install without --allow-external to fail"; exit 1
fi

(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" skills install "$FIXTURE" --skill external-audit --allow-external --yes)
[[ -f "$TMP/.agents/skills/external-audit/SKILL.md" ]]
jq -e '.externals|length==1' "$TMP/skills-lock.json" >/dev/null
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/scripts/08-external-install.sh`  
Expected: FAIL (external flow 미구현)

**Step 3: Write minimal implementation**

```js
// lib/installer.js
if (isExternal(source) && !flags.allowExternal) {
  throw new Error('External source requires --allow-external');
}
// local path external MVP: copy from <source>/skills/<skillName> to .agents/skills/<skillName>
```

**Step 4: Run test to verify it passes**

Run: `bash tests/smoke/scripts/08-external-install.sh`  
Expected: PASS, external 설치와 lock externals 기록 확인

**Step 5: Commit**

```bash
git add lib/installer.js tests/fixtures/external-skills-repo/skills/external-audit/SKILL.md tests/smoke/scripts/08-external-install.sh
git commit -m "feat: support external skill install with explicit allow flag"
```

### Task 6: `audit` 명령 구현

**Files:**
- Create: `lib/auditor.js`
- Modify: `lib/cli.js`
- Create: `tests/smoke/scripts/09-audit.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT=$(node "$ROOT/bin/agent-foundry.js" audit --format json)

echo "$OUT" | jq -e 'has("status") and has("checks") and (.checks|type=="array")' >/dev/null
echo "$OUT" | jq -e '.checks[] | has("id") and has("status") and has("message")' >/dev/null
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/scripts/09-audit.sh`  
Expected: FAIL (audit output contract 미구현)

**Step 3: Write minimal implementation**

```js
// lib/auditor.js
function runAudit({ repoRoot }) {
  const checks = [
    checkCatalog(repoRoot),
    checkManifestParity(repoRoot),
    checkDocsBaseline(repoRoot),
    checkLockShape(repoRoot)
  ];
  return {
    status: checks.some((c) => c.status === 'FAIL') ? 'FAIL' : checks.some((c) => c.status === 'WARN') ? 'WARN' : 'PASS',
    checks
  };
}
```

**Step 4: Run test to verify it passes**

Run: `bash tests/smoke/scripts/09-audit.sh`  
Expected: PASS, JSON contract 유지

**Step 5: Commit**

```bash
git add lib/auditor.js lib/cli.js tests/smoke/scripts/09-audit.sh
git commit -m "feat: add repository audit command with pass/warn/fail checks"
```

### Task 7: `docs suggest` 구현

**Files:**
- Modify: `lib/doc-writer.js`
- Modify: `lib/cli.js`
- Create: `tests/smoke/scripts/10-docs-suggest.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -R "$ROOT/manifests" "$TMP/manifests"

(cd "$TMP" && OUT=$(node "$ROOT/bin/agent-foundry.js" docs suggest))
echo "$OUT" | grep -q "docs/goal.md"
echo "$OUT" | grep -q "templates/handoff/goal.md"
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/scripts/10-docs-suggest.sh`  
Expected: FAIL (docs suggestion 미구현)

**Step 3: Write minimal implementation**

```js
// lib/doc-writer.js
function suggestDocs({ repoRoot, catalog }) {
  return catalog.docs
    .filter((d) => !fs.existsSync(path.join(repoRoot, d.destination)))
    .map((d) => ({ ...d, reason: 'missing file' }));
}
```

**Step 4: Run test to verify it passes**

Run: `bash tests/smoke/scripts/10-docs-suggest.sh`  
Expected: PASS

**Step 5: Commit**

```bash
git add lib/doc-writer.js lib/cli.js tests/smoke/scripts/10-docs-suggest.sh
git commit -m "feat: add docs suggest command based on catalog templates"
```

### Task 8: `docs write --yes` 구현 + 질문 흐름

**Files:**
- Create: `lib/prompt.js`
- Modify: `lib/doc-writer.js`
- Modify: `lib/cli.js`
- Create: `tests/smoke/scripts/11-docs-write.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/manifests" "$TMP/templates/handoff"
cp "$ROOT/manifests/catalog.json" "$TMP/manifests/catalog.json"
cp "$ROOT/templates/handoff/goal.md" "$TMP/templates/handoff/goal.md"

(cd "$TMP" && node "$ROOT/bin/agent-foundry.js" docs write goal --yes >/dev/null)
[[ -f "$TMP/docs/goal.md" ]]
grep -q "TODO" "$TMP/docs/goal.md"
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/scripts/11-docs-write.sh`  
Expected: FAIL (`docs write` 미구현)

**Step 3: Write minimal implementation**

```js
// lib/doc-writer.js
function writeDoc({ type, repoRoot, yes }) {
  const mapping = resolveDocMapping(type);
  const raw = fs.readFileSync(path.join(repoRoot, mapping.source), 'utf8');
  const rendered = yes ? raw + '\n\n<!-- TODO: project-specific details -->\n' : raw;
  writeTarget(path.join(repoRoot, mapping.destination), rendered);
}
```

**Step 4: Run test to verify it passes**

Run: `bash tests/smoke/scripts/11-docs-write.sh`  
Expected: PASS

**Step 5: Commit**

```bash
git add lib/prompt.js lib/doc-writer.js lib/cli.js tests/smoke/scripts/11-docs-write.sh
git commit -m "feat: implement docs write command with non-interactive mode"
```

### Task 9: Legacy 스크립트/문서 정합성 마무리

**Files:**
- Modify: `scripts/bootstrap-project.sh`
- Modify: `scripts/update-skills.sh`
- Modify: `README.md`
- Modify: `manifests/skills.json`
- Modify: `manifests/templates.json`
- Modify: `tests/smoke/scripts/02-bootstrap.sh`
- Modify: `tests/smoke/scripts/03-update-skills.sh`

**Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# README quick-start commands must work
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash "$ROOT/scripts/bootstrap-project.sh" --repo-root "$ROOT" --target "$TMP" --template fullstack --skills coding-conventions
[[ -f "$TMP/skills-lock.json" ]]
jq -e '.schemaVersion == 2' "$TMP/skills-lock.json" >/dev/null
```

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke/run-all.sh`  
Expected: FAIL (README/legacy behavior와 새 CLI 정합성 불충분)

**Step 3: Write minimal implementation**

```bash
# scripts/bootstrap-project.sh (legacy wrapper)
node "$REPO_ROOT/bin/agent-foundry.js" skills install "$SKILL" --repo "$TARGET"
```

README 최소 정합 원칙:
1. 존재하는 템플릿만 예시
2. manifest 등록된 스킬만 예시
3. lock v2 구조 예시 반영

**Step 4: Run test to verify it passes**

Run:
1. `bash tests/smoke/run-all.sh`
2. `node bin/agent-foundry.js audit --format json | jq -e '.status'`  
Expected: PASS

**Step 5: Commit**

```bash
git add scripts/bootstrap-project.sh scripts/update-skills.sh README.md manifests/skills.json manifests/templates.json tests/smoke/scripts/02-bootstrap.sh tests/smoke/scripts/03-update-skills.sh
git commit -m "fix: align legacy scripts and docs with new work harness contracts"
```

### Task 10: 최종 검증 및 변경 요약 문서화

**Files:**
- Modify: `docs/plans/2026-03-19-agent-foundry-work-harness-implementation.md` (status update)
- (Optional) Create: `docs/plans/2026-03-19-agent-foundry-work-harness-implementation-report.md`

**Step 1: Write the failing test**

실패 테스트 대신 릴리스 게이트 체크리스트를 만든다:

```bash
bash tests/smoke/run-all.sh
node bin/agent-foundry.js skills search coding --source curated
node bin/agent-foundry.js audit --format text
node bin/agent-foundry.js docs suggest
```

**Step 2: Run verification to capture current failures**

Run above commands and capture non-zero exits.

**Step 3: Write minimal implementation fixes**

게이트에서 실패한 부분만 최소 수정(YAGNI)으로 반영한다.

**Step 4: Re-run verification**

Run above commands again.  
Expected: all PASS / non-zero 없음

**Step 5: Commit**

```bash
git add .
git commit -m "chore: finalize work harness implementation and verification evidence"
```

## 실행 시 참고 스킬

1. `@test-driven-development` (각 태스크 RED→GREEN 유지)
2. `@verification-before-completion` (완료 주장 전 증거 확보)
3. `@skill-creator` (`SKILL.md`/manifest 정합성 점검)
4. `@receiving-code-review` (리뷰 피드백 반영 시 검증)

## 완료 기준

1. `skills search/install/audit/docs` 명령이 smoke에서 검증된다.
2. curated/external 설치가 lock v2에 일관되게 기록된다.
3. README 예시 커맨드가 실제로 동작한다.
4. legacy 스크립트와 신규 CLI가 동일 계약(입력/출력)을 따른다.
5. `bash tests/smoke/run-all.sh` 전체 통과 상태가 유지된다.
