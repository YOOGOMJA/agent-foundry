#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

node -e "JSON.parse(require('fs').readFileSync('$ROOT/manifests/templates.json','utf8'))"   || { echo "FAIL: templates.json invalid JSON"; exit 1; }
node -e "JSON.parse(require('fs').readFileSync('$ROOT/manifests/skills.json','utf8'))"   || { echo "FAIL: skills.json invalid JSON"; exit 1; }

node -e "
  const t = JSON.parse(require('fs').readFileSync('$ROOT/manifests/templates.json','utf8'));
  if (!t.fullstack) throw new Error('fullstack template missing');
  if (!Array.isArray(t.fullstack.files)) throw new Error('files must be array');
  if (!Array.isArray(t.fullstack.skills)) throw new Error('skills must be array');
  if (!t.fullstack.placeholders) throw new Error('placeholders missing');
  console.log('templates.json structure OK');
"

node -e "
  const fs = require('fs');
  const path = require('path');
  const s = JSON.parse(fs.readFileSync('$ROOT/manifests/skills.json','utf8'));
  if (!s['coding-conventions']) throw new Error('coding-conventions missing');
  const skillPath = path.join('$ROOT', s['coding-conventions'].path);
  const stat = fs.statSync(skillPath);
  if (!stat.isDirectory()) throw new Error('Skill path is not a directory');
  if (!fs.existsSync(path.join(skillPath, 'SKILL.md'))) throw new Error('SKILL.md missing');
  console.log('skills.json structure OK');
"

node -e "
  const fs = require('fs');
  const path = require('path');
  const t = JSON.parse(fs.readFileSync('$ROOT/manifests/templates.json','utf8'));
  for (const entry of t.fullstack.files) {
    const src = entry.split(' -> ')[0].trim();
    const full = path.join('$ROOT', src);
    if (!fs.existsSync(full)) throw new Error('File not found: ' + src);
  }
  const s = JSON.parse(fs.readFileSync('$ROOT/manifests/skills.json','utf8'));
  for (const skill of t.fullstack.skills) {
    const skillPath = path.join('$ROOT', s[skill].path);
    if (!fs.existsSync(skillPath)) throw new Error('Skill dir not found: ' + skill);
  }
  console.log('manifest file references OK');
"

node -e "
  const p = JSON.parse(require('fs').readFileSync('$ROOT/package.json','utf8'));
  if (!p.bin || !p.bin['agent-foundry']) throw new Error('bin.agent-foundry missing');
  if (p.dependencies && Object.keys(p.dependencies).length > 0) throw new Error('external dependencies not allowed');
  console.log('package.json OK');
"

echo "OK: manifests"
