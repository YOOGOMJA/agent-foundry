#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

bash "$ROOT/tests/smoke/docs/01-required-docs.sh"
bash "$ROOT/tests/smoke/manifest/01-manifest-shape.sh"
bash "$ROOT/tests/smoke/manifest/02-catalog-shape.sh"
bash "$ROOT/tests/smoke/scripts/01-install-skill.sh"
bash "$ROOT/tests/smoke/scripts/02-bootstrap.sh"
bash "$ROOT/tests/smoke/scripts/03-update-skills.sh"
bash "$ROOT/tests/smoke/scripts/04-cli-subcommands.sh"
bash "$ROOT/tests/smoke/scripts/05-skills-search.sh"
bash "$ROOT/tests/smoke/scripts/06-skills-install-lock-v2.sh"
bash "$ROOT/tests/smoke/scripts/07-update-lock-migration.sh"
bash "$ROOT/tests/smoke/scripts/08-external-install.sh"
bash "$ROOT/tests/smoke/scripts/09-lock-merge-sequential.sh"
bash "$ROOT/tests/smoke/scripts/10-traversal-rejected.sh"
bash "$ROOT/tests/smoke/scripts/11-unknown-external-kind-fails.sh"
bash "$ROOT/tests/smoke/docs/02-adr-and-plan-docs.sh"
