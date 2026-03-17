#!/usr/bin/env node
// bin/agent-foundry.js — agent-foundry CLI
// Node 18+ built-in only: fs, path, process
'use strict';

const fs = require('fs');
const path = require('path');

// ── 인자 파싱 ────────────────────────────────────────────────
const args = process.argv.slice(2);
const flags = {};
for (let i = 0; i < args.length; i++) {
  if (args[i].startsWith('--')) {
    flags[args[i].slice(2)] = args[i + 1] !== undefined ? args[i + 1] : '';
    i++;
  }
}

const template    = flags.template || null;
const skillsFlag  = flags.skills ? flags.skills.split(',').map(s => s.trim()).filter(Boolean) : [];
const projectName = flags.name || path.basename(process.cwd());
const githubRepo  = flags.repo  || '';
const outputDir   = flags.output ? path.resolve(flags.output) : process.cwd();

if (!template && skillsFlag.length === 0) {
  console.error('Error: --template or --skills is required');
  process.exit(1);
}

// ── 경로 설정 ────────────────────────────────────────────────
const ROOT = path.join(__dirname, '..');
const manifestsDir = path.join(ROOT, 'manifests');

// ── 헬퍼 ────────────────────────────────────────────────────
function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function applyPlaceholders(content, placeholders) {
  let result = content;
  for (const [key, value] of Object.entries(placeholders)) {
    result = result.split(`{{${key}}}`).join(value);
  }
  return result;
}

function copyFile(src, dest, placeholders) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  const raw = fs.readFileSync(src, 'utf8');
  fs.writeFileSync(dest, applyPlaceholders(raw, placeholders), 'utf8');
}

function copyDir(src, dest, placeholders) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath, placeholders);
    } else {
      copyFile(srcPath, destPath, placeholders);
    }
  }
}

// ── 실행 ────────────────────────────────────────────────────
const placeholders   = { PROJECT_NAME: projectName, GITHUB_REPO: githubRepo };
const skillsManifest = readJson(path.join(manifestsDir, 'skills.json'));
let installedSkills  = [...skillsFlag];

if (template) {
  const templatesManifest = readJson(path.join(manifestsDir, 'templates.json'));
  const tmpl = templatesManifest[template];
  if (!tmpl) {
    console.error(`Error: unknown template "${template}"`);
    process.exit(1);
  }
  for (const entry of tmpl.files) {
    const [srcRel, destRel] = entry.split(' -> ').map(s => s.trim());
    copyFile(path.join(ROOT, srcRel), path.join(outputDir, destRel), placeholders);
  }
  for (const s of tmpl.skills) {
    if (!installedSkills.includes(s)) installedSkills.push(s);
  }
}

for (const skillName of installedSkills) {
  const skill = skillsManifest[skillName];
  if (!skill) {
    console.error(`Error: unknown skill "${skillName}"`);
    process.exit(1);
  }
  copyDir(
    path.join(ROOT, skill.path),
    path.join(outputDir, '.agents', 'skills', skillName),
    placeholders
  );
}

const lock = {
  installedAt: new Date().toISOString(),
  source: 'github:kyeongsoo-yoo/agent-foundry',
  ref: 'local',
  template: template || null,
  skills: installedSkills,
};
fs.writeFileSync(path.join(outputDir, 'skills-lock.json'), JSON.stringify(lock, null, 2), 'utf8');

console.log(`\n✓ agent-foundry init complete — ${projectName}`);
console.log(`  template : ${template || '(none)'}`);
console.log(`  skills   : ${installedSkills.join(', ')}`);
if (template) console.log(`\nNext: see NEXT_STEPS.md`);
