#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

bash "$ROOT/tests/smoke/docs/01-required-docs.sh"
bash "$ROOT/tests/smoke/manifest/01-manifest-shape.sh"
bash "$ROOT/tests/smoke/scripts/01-install-skill.sh"
bash "$ROOT/tests/smoke/scripts/02-bootstrap.sh"
bash "$ROOT/tests/smoke/scripts/03-update-skills.sh"
bash "$ROOT/tests/smoke/docs/02-adr-and-plan-docs.sh"
