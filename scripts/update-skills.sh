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

SOURCE="$(jq -r 'if has("source") then .source else "github:kyeongsoo-yoo/agent-foundry" end' "$LOCK_FILE")"
TEMPLATE="$(jq -c 'if has("template") then .template else null end' "$LOCK_FILE")"
REF="$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || printf 'local')"
INSTALLED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

validate_skill_name() {
  local name="$1"
  [[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]] || return 1
  case "$name" in
    *[\\/]*|*..*)
      return 1
      ;;
  esac
}

SKILLS_BASE=""
mkdir -p "$TARGET/.agents/skills"
SKILLS_BASE="$(cd "$TARGET/.agents/skills" && pwd -P)"

while IFS=$'\t' read -r kind source_path skill_name; do
  [[ -n "$kind" || -n "$source_path" || -n "$skill_name" ]] || continue
  validate_skill_name "$skill_name" || {
    echo "invalid external skill name in lock: $skill_name" >&2
    exit 1
  }
  case "$kind" in
    git-copy|local-copy)
      ;;
    *)
      echo "unknown external kind: $kind" >&2
      exit 1
      ;;
  esac
done < <(jq -r '.externals[]? | [.kind // "", .source // "", (.skills[0] // .skill // "")] | @tsv' "$LOCK_FILE")

while IFS= read -r skill; do
  [[ -n "$skill" ]] || continue
  bash "$REPO_ROOT/scripts/install-skill.sh" \
    --repo-root "$REPO_ROOT" \
    --target "$TARGET" \
    --skill "$skill" \
    --force
done < <(jq -r '.skills[]?' "$LOCK_FILE")

while IFS=$'\t' read -r source_path skill_name kind; do
  [[ -n "$source_path" && -n "$skill_name" ]] || continue
  validate_skill_name "$skill_name" || {
    echo "invalid external skill name in lock: $skill_name" >&2
    exit 1
  }
  source_dir="$source_path/skills/$skill_name"
  target_dir="$TARGET/.agents/skills/$skill_name"
  if [[ ! -d "$source_dir" ]]; then
    echo "external skill source missing: $source_dir" >&2
    exit 1
  fi
  target_dir_resolved="$SKILLS_BASE/$skill_name"
  case "$target_dir_resolved" in
    "$SKILLS_BASE"/*) ;;
    *)
      echo "invalid external destination: $target_dir_resolved" >&2
      exit 1
      ;;
  esac
  rm -rf "$target_dir"
  mkdir -p "$(dirname "$target_dir")"
  cp -R "$source_dir" "$target_dir"
done < <(jq -r '.externals[]? as $external | ($external.skills // [$external.skill])[]? as $skill | [$external.source, $skill, ($external.kind // "")] | @tsv' "$LOCK_FILE")

SKILLS_JSON="$(jq -c '[.skills[]?]' "$LOCK_FILE")"
EXTERNALS_JSON="$(jq -c '(.externals // [])' "$LOCK_FILE")"

jq -n \
  --arg schemaVersion "2" \
  --arg installedAt "$INSTALLED_AT" \
  --arg source "$SOURCE" \
  --arg ref "$REF" \
  --argjson template "$TEMPLATE" \
  --argjson skills "$SKILLS_JSON" \
  --argjson externals "$EXTERNALS_JSON" \
  '{schemaVersion: ($schemaVersion | tonumber), installedAt: $installedAt, source: $source, ref: $ref, template: $template, skills: $skills, externals: $externals}' \
  > "$LOCK_FILE"
