#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bootstrap-project.sh --repo-root <path> --target <path> --template <name> --skills <csv>
USAGE
}

REPO_ROOT=""
TARGET=""
TEMPLATE=""
SKILLS_RAW=""

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
    --template)
      TEMPLATE="${2:-}"
      shift 2
      ;;
    --skills)
      SKILLS_RAW="${2:-}"
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

if [[ -z "$REPO_ROOT" || -z "$TARGET" || -z "$TEMPLATE" ]]; then
  usage >&2
  exit 1
fi

TEMPLATE_FILE="$REPO_ROOT/templates/agents/$TEMPLATE.md"
if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "template not found: $TEMPLATE_FILE" >&2
  exit 1
fi

mkdir -p "$TARGET"
cp "$TEMPLATE_FILE" "$TARGET/AGENTS.md"

SKILL_LIST=()
if [[ -n "$SKILLS_RAW" ]]; then
  IFS=',' read -r -a TOKENS <<< "$SKILLS_RAW"
  for token in "${TOKENS[@]}"; do
    skill="$(echo "$token" | xargs)"
    [[ -n "$skill" ]] || continue
    SKILL_LIST+=("$skill")
    bash "$REPO_ROOT/scripts/install-skill.sh" \
      --repo-root "$REPO_ROOT" \
      --target "$TARGET" \
      --skill "$skill"
  done
fi

MANIFEST="$REPO_ROOT/manifests/skills.json"
if [[ ! -f "$MANIFEST" ]]; then
  echo "manifest not found: $MANIFEST" >&2
  exit 1
fi

if [[ ${#SKILL_LIST[@]} -gt 0 ]]; then
  SKILLS_JSON="$(printf '%s\n' "${SKILL_LIST[@]}" | jq -R . | jq -s .)"
else
  SKILLS_JSON='[]'
fi

INSTALLED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

jq -n \
  --arg hub "YOOGOMJA/agent-foundry" \
  --arg installedAt "$INSTALLED_AT" \
  --argjson skills "$SKILLS_JSON" \
  '{hub: $hub, installedAt: $installedAt, skills: $skills}' \
  > "$TARGET/skills-lock.json"
