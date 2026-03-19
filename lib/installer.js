'use strict';

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const AGENT_FOUNDRY_SOURCE = 'github:kyeongsoo-yoo/agent-foundry';
const SAFE_SKILL_RE = /^[a-z0-9][a-z0-9-]*$/;

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(value, null, 2), 'utf8');
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

function copyDir(src, dest, placeholders = {}) {
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

function validateSkillName(name, context) {
  if (typeof name !== 'string' || !SAFE_SKILL_RE.test(name) || /[\\/]/.test(name) || name.includes('..')) {
    throw new Error(`Error: invalid ${context}: "${name}"`);
  }
  return name;
}

function ensureInsideBase(baseDir, candidatePath, context) {
  const baseResolved = path.resolve(baseDir);
  const candidateResolved = path.resolve(candidatePath);
  const prefix = baseResolved.endsWith(path.sep) ? baseResolved : `${baseResolved}${path.sep}`;

  if (candidateResolved !== baseResolved && !candidateResolved.startsWith(prefix)) {
    throw new Error(`Error: invalid ${context}`);
  }

  return candidateResolved;
}

function getGitHead(dir) {
  if (!fs.existsSync(path.join(dir, '.git'))) {
    return 'local';
  }

  try {
    return execFileSync('git', ['-C', dir, 'rev-parse', 'HEAD'], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
  } catch {
    return 'local';
  }
}

function loadCuratedSkill(repoRoot, skillName) {
  const safeName = validateSkillName(skillName, 'curated skill name');
  const catalogPath = path.join(repoRoot, 'manifests', 'catalog.json');
  if (fs.existsSync(catalogPath)) {
    const catalog = readJson(catalogPath);
    const skill = (catalog.skills || []).find((entry) => entry.name === safeName && entry.trust !== 'external');
    if (skill) return skill;
  }

  const skillsManifestPath = path.join(repoRoot, 'manifests', 'skills.json');
  if (fs.existsSync(skillsManifestPath)) {
    const skillsManifest = readJson(skillsManifestPath);
    const skill = skillsManifest[safeName];
    if (skill) return { name: safeName, ...skill };
  }

  return null;
}

function readExistingLock(targetDir) {
  const lockPath = path.join(targetDir, 'skills-lock.json');
  if (!fs.existsSync(lockPath)) {
    return null;
  }

  return readJson(lockPath);
}

function normalizeSkills(skills) {
  const output = [];
  for (const skill of skills || []) {
    const safeSkill = validateSkillName(skill, 'lock skill name');
    if (!output.includes(safeSkill)) {
      output.push(safeSkill);
    }
  }
  return output;
}

function normalizeExternalEntry(entry) {
  const kind = String(entry.kind || 'git-copy');
  const source = String(entry.source || '');
  const ref = String(entry.ref || 'local');
  const rawSkills = Array.isArray(entry.skills) && entry.skills.length > 0 ? entry.skills : [entry.skill];
  const skills = normalizeSkills(rawSkills.filter(Boolean));

  if (!source) {
    throw new Error('Error: invalid lock external entry');
  }
  if (skills.length === 0) {
    throw new Error('Error: invalid lock external entry');
  }

  return { source, ref, kind, skills };
}

function normalizeExternals(externals) {
  return (externals || []).map((entry) => normalizeExternalEntry(entry));
}

function mergeUnique(existing, additions) {
  const merged = [...existing];
  for (const item of additions) {
    if (!merged.includes(item)) {
      merged.push(item);
    }
  }
  return merged;
}

function mergeExternalEntries(existing, additions) {
  const merged = [...existing];
  const seen = new Set(
    merged.map((entry) => JSON.stringify({
      source: entry.source,
      ref: entry.ref,
      kind: entry.kind,
      skills: entry.skills,
    }))
  );

  for (const entry of additions) {
    const normalized = normalizeExternalEntry(entry);
    const signature = JSON.stringify({
      source: normalized.source,
      ref: normalized.ref,
      kind: normalized.kind,
      skills: normalized.skills,
    });
    if (!seen.has(signature)) {
      merged.push(normalized);
      seen.add(signature);
    }
  }

  return merged;
}

function resolveSkillsBase(targetDir) {
  fs.mkdirSync(path.join(targetDir, '.agents', 'skills'), { recursive: true });
  return path.resolve(targetDir, '.agents', 'skills');
}

function resolveSkillDestination(targetDir, skillName) {
  const safeSkill = validateSkillName(skillName, 'skill name');
  const skillsBase = resolveSkillsBase(targetDir);
  const destDir = ensureInsideBase(skillsBase, path.join(skillsBase, safeSkill), 'skill destination');
  return { skillsBase, destDir, skillName: safeSkill };
}

function installCuratedSkill({ repoRoot, targetDir, skillName }) {
  const skill = loadCuratedSkill(repoRoot, skillName);
  if (!skill || !skill.path) {
    throw new Error(`Error: unknown skill "${skillName}"`);
  }

  const sourceDir = path.join(repoRoot, skill.path);
  const { destDir, skillName: safeSkillName } = resolveSkillDestination(targetDir, skillName);
  fs.rmSync(destDir, { recursive: true, force: true });
  copyDir(sourceDir, destDir, {});
  return safeSkillName;
}

function installExternalSkill({ sourcePath, targetDir, skillName }) {
  const resolvedSource = path.resolve(sourcePath);
  const sourceDir = path.join(resolvedSource, 'skills', validateSkillName(skillName, 'external skill name'));
  if (!fs.existsSync(sourceDir)) {
    throw new Error(`Error: unknown external skill "${skillName}"`);
  }

  const { destDir, skillName: safeSkillName } = resolveSkillDestination(targetDir, skillName);
  fs.rmSync(destDir, { recursive: true, force: true });
  copyDir(sourceDir, destDir, {});
  return {
    source: resolvedSource,
    ref: getGitHead(resolvedSource),
    kind: 'git-copy',
    skills: [safeSkillName],
  };
}

function buildLock({ repoRoot, existingLock, skillNames, externals }) {
  const currentLock = existingLock || {};
  const mergedSkills = mergeUnique(normalizeSkills(currentLock.skills || []), skillNames.map((name) => validateSkillName(name, 'skill name')));
  const mergedExternals = mergeExternalEntries(normalizeExternals(currentLock.externals || []), externals);

  return {
    schemaVersion: 2,
    installedAt: new Date().toISOString(),
    source: currentLock.source || AGENT_FOUNDRY_SOURCE,
    ref: currentLock.ref || getGitHead(repoRoot),
    template: Object.prototype.hasOwnProperty.call(currentLock, 'template') ? currentLock.template : null,
    skills: mergedSkills,
    externals: mergedExternals,
  };
}

function writeLockV2({ repoRoot, targetDir, skillNames, externals }) {
  const existingLock = readExistingLock(targetDir);
  const lock = buildLock({ repoRoot, existingLock, skillNames, externals });
  writeJson(path.join(targetDir, 'skills-lock.json'), lock);
  return lock;
}

function installSkill({ repoRoot, targetDir, source, skillName, allowExternal = false }) {
  const skillNames = [];
  const externals = [];

  if (skillName) {
    if (!allowExternal) {
      throw new Error('Error: External source requires --allow-external');
    }
    externals.push(installExternalSkill({ sourcePath: source, targetDir, skillName }));
  } else {
    skillNames.push(installCuratedSkill({ repoRoot, targetDir, skillName: source }));
  }

  return writeLockV2({
    repoRoot,
    targetDir,
    skillNames,
    externals,
  });
}

module.exports = {
  getGitHead,
  installSkill,
  writeLockV2,
  validateSkillName,
  ensureInsideBase,
};
