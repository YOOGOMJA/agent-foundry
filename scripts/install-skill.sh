#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install-skill.sh --repo-root <path> --target <path> --skill <name> [--force]
USAGE
}

REPO_ROOT=""
TARGET=""
SKILL=""
FORCE=0

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
    --skill)
      SKILL="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
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

if [[ -z "$REPO_ROOT" || -z "$TARGET" || -z "$SKILL" ]]; then
  usage >&2
  exit 1
fi

MANIFEST="$REPO_ROOT/manifests/skills.json"
if [[ ! -f "$MANIFEST" ]]; then
  echo "manifest not found: $MANIFEST" >&2
  exit 1
fi

SKILL_PATH="$(jq -r --arg name "$SKILL" '.skills[] | select(.name == $name) | .path' "$MANIFEST")"
if [[ -z "$SKILL_PATH" || "$SKILL_PATH" == "null" ]]; then
  echo "skill not found in manifest: $SKILL" >&2
  exit 1
fi

SOURCE_DIR="$REPO_ROOT/$SKILL_PATH"
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "skill source missing: $SOURCE_DIR" >&2
  exit 1
fi

TARGET_DIR="$TARGET/.agents/skills/$SKILL"
if [[ -e "$TARGET_DIR" && "$FORCE" -ne 1 ]]; then
  echo "skill already exists: $TARGET_DIR (use --force)" >&2
  exit 1
fi

mkdir -p "$TARGET/.agents/skills"
if [[ -e "$TARGET_DIR" ]]; then
  rm -rf "$TARGET_DIR"
fi
cp -R "$SOURCE_DIR" "$TARGET_DIR"
