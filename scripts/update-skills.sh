#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: update-skills.sh --repo-root <path> --target <path>
USAGE
}

REPO_ROOT=""
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      REPO_ROOT="${2:-}"
      shift 2
      ;;
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$REPO_ROOT" || -z "$TARGET" ]]; then
  usage >&2
  exit 1
fi

LOCK_FILE="$TARGET/skills-lock.json"
if [[ ! -f "$LOCK_FILE" ]]; then
  echo "lock file not found: $LOCK_FILE" >&2
  exit 1
fi

MANIFEST="$REPO_ROOT/manifests/skills.json"
if [[ ! -f "$MANIFEST" ]]; then
  echo "manifest not found: $MANIFEST" >&2
  exit 1
fi

LOCK_VERSION="$(jq -r '.version' "$LOCK_FILE")"
MANIFEST_VERSION="$(jq -r '.version' "$MANIFEST")"
EXPECTED_VERSION="v$MANIFEST_VERSION"

if [[ "$LOCK_VERSION" != "$EXPECTED_VERSION" ]]; then
  echo "lock version mismatch: lock=$LOCK_VERSION manifest=$EXPECTED_VERSION" >&2
  echo "update aborted. align lock version explicitly before retrying." >&2
  exit 1
fi

while IFS= read -r skill; do
  [[ -n "$skill" ]] || continue
  bash "$REPO_ROOT/scripts/install-skill.sh" \
    --repo-root "$REPO_ROOT" \
    --target "$TARGET" \
    --skill "$skill" \
    --force
done < <(jq -r '.skills[]' "$LOCK_FILE")
