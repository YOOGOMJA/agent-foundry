#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

[[ -f "$ROOT/manifests/catalog.json" ]] || { echo "missing catalog.json"; exit 1; }
jq -e '
  (has("skills") and (.skills | type == "array") and (.skills | length > 0)) and
  (has("docs") and (.docs | type == "array")) and
  (.skills | all(
    has("name") and has("description") and has("install") and has("trust") and
    (.trust != "curated" or has("path"))
  )) and
  (.docs | all(has("type") and has("source") and has("destination")))
' "$ROOT/manifests/catalog.json" >/dev/null
