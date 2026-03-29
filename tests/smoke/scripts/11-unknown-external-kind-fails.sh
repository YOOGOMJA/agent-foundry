#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/skills-lock.json" <<'JSON'
{
  "schemaVersion": 2,
  "installedAt": "2026-03-19T00:00:00Z",
  "source": "github:kyeongsoo-yoo/agent-foundry",
  "ref": "local",
  "template": null,
  "skills": ["coding-conventions"],
  "externals": [
    {
      "source": "/tmp/external",
      "ref": "local",
      "kind": "bogus-kind",
      "skills": ["external-audit"]
    }
  ]
}
JSON

if bash "$ROOT/scripts/update-skills.sh" --repo-root "$ROOT" --target "$TMP" 2>/dev/null; then
  echo "expected unknown external kind to fail"
  exit 1
fi

