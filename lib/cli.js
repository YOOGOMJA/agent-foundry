'use strict';

const fs = require('fs');
const path = require('path');

const { catalogPathFromRoot, findCatalogSkill, loadCatalog, searchSkills } = require('./catalog');
const { formatAuditText, runAudit } = require('./auditor');
const { formatDocSuggestions, suggestDocs, writeDoc } = require('./doc-writer');
const { getGitHead, installSkill } = require('./installer');

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

function parseFlags(args) {
  const flags = {};
  for (let i = 0; i < args.length; i++) {
    if (!args[i].startsWith('--')) continue;
    const key = args[i].slice(2);
    const value = args[i + 1] !== undefined && !args[i + 1].startsWith('--') ? args[i + 1] : '';
    flags[key] = value;
    if (value !== '') i++;
  }
  return flags;
}

function parseArgs(args) {
  const flags = {};
  const positionals = [];

  for (let i = 0; i < args.length; i++) {
    const token = args[i];
    if (!token.startsWith('--')) {
      positionals.push(token);
      continue;
    }

    const key = token.slice(2);
    const next = args[i + 1];
    const hasValue = next !== undefined && !next.startsWith('--');
    flags[key] = hasValue ? next : '';
    if (hasValue) i++;
  }

  return { flags, positionals };
}

function formatSkillResult(skill) {
  const installKind = skill.install && skill.install.kind ? skill.install.kind : 'unknown';
  return `${skill.name}\t[${skill.trust}/${installKind}]\t${skill.description}`;
}

function isSubcommandMode(args) {
  return args.length > 0 && !args[0].startsWith('--');
}

function resolveRepoRoot(flags) {
  return flags.repo ? path.resolve(flags.repo) : process.cwd();
}

function handleSkillsCommand(args, rootDir) {
  const subcommand = args[0];
  if (!subcommand) {
    throw new Error('Error: missing skills subcommand');
  }

  if (subcommand === 'search') {
    const rest = args.slice(1);
    const { flags, positionals } = parseArgs(rest);
    const query = positionals[0] || '';
    const source = flags.source || 'curated';
    const catalog = loadCatalog(catalogPathFromRoot(rootDir));
    const results = searchSkills({ catalog, query, source });
    for (const skill of results) {
      console.log(formatSkillResult(skill));
    }
    return;
  }

  if (subcommand === 'install') {
    const rest = args.slice(1);
    const { flags, positionals } = parseArgs(rest);
    const source = positionals[0];
    if (!source) {
      throw new Error('Error: missing skills install target');
    }

    const targetDir = flags.output ? path.resolve(flags.output) : process.cwd();
    const allowExternal = Object.prototype.hasOwnProperty.call(flags, 'allow-external');
    const externalSkill = flags.skill || '';

    return installSkill({
      repoRoot: rootDir,
      targetDir,
      source,
      skillName: externalSkill || null,
      allowExternal,
    });
  }

  throw new Error(`Error: unknown skills subcommand "${subcommand}"`);
}

function handleAuditCommand(args, rootDir) {
  const { flags } = parseArgs(args);
  const projectRoot = resolveRepoRoot(flags);
  const result = runAudit({ projectRoot, toolRoot: rootDir });
  const format = flags.format || 'text';

  if (!['text', 'json'].includes(format)) {
    throw new Error(`Error: invalid audit format "${format}"`);
  }

  if (format === 'json') {
    console.log(JSON.stringify(result, null, 2));
    return result;
  }

  process.stdout.write(formatAuditText(result));
  return result;
}

async function handleDocsCommand(args, rootDir) {
  const subcommand = args[0];
  const rest = args.slice(1);
  const { flags, positionals } = parseArgs(rest);
  const projectRoot = resolveRepoRoot(flags);

  if (subcommand === 'suggest') {
    const suggestions = suggestDocs({ projectRoot, toolRoot: rootDir });
    process.stdout.write(formatDocSuggestions(suggestions));
    return suggestions;
  }

  if (subcommand === 'write') {
    const docType = positionals[0];
    if (!docType) {
      throw new Error('Error: missing docs write target');
    }

    return writeDoc({
      projectRoot,
      toolRoot: rootDir,
      docType,
      yes: Object.prototype.hasOwnProperty.call(flags, 'yes'),
    });
  }

  throw new Error(`Error: unknown docs subcommand "${subcommand || ''}"`);
}

async function runSubcommand(args, rootDir) {
  const [group, ...rest] = args;
  if (group === 'skills') return handleSkillsCommand(rest, rootDir);
  if (group === 'audit') return handleAuditCommand(rest, rootDir);
  if (group === 'docs') return handleDocsCommand(rest, rootDir);
  throw new Error(`Error: unknown command "${group}"`);
}

function runLegacy({ args, rootDir }) {
  const flags = parseFlags(args);
  const template = flags.template || null;
  const skillsFlag = flags.skills ? flags.skills.split(',').map((s) => s.trim()).filter(Boolean) : [];
  const projectName = flags.name || path.basename(process.cwd());
  const githubRepo = flags.repo || '';
  const outputDir = flags.output ? path.resolve(flags.output) : process.cwd();

  if (!template && skillsFlag.length === 0) {
    throw new Error('Error: --template or --skills is required');
  }

  const manifestsDir = path.join(rootDir, 'manifests');
  const catalog = loadCatalog(catalogPathFromRoot(rootDir));
  const placeholders = { PROJECT_NAME: projectName, GITHUB_REPO: githubRepo };
  const skillsManifest = readJson(path.join(manifestsDir, 'skills.json'));
  const templatesManifest = template ? readJson(path.join(manifestsDir, 'templates.json')) : null;
  let installedSkills = [...skillsFlag];

  if (template) {
    const tmpl = templatesManifest[template];
    if (!tmpl) {
      throw new Error(`Error: unknown template "${template}"`);
    }
    for (const entry of tmpl.files) {
      const [srcRel, destRel] = entry.split(' -> ').map((s) => s.trim());
      copyFile(path.join(rootDir, srcRel), path.join(outputDir, destRel), placeholders);
    }
    for (const skillName of tmpl.skills) {
      if (!installedSkills.includes(skillName)) installedSkills.push(skillName);
    }
  }

  for (const skillName of installedSkills) {
    const skill = findCatalogSkill(catalog, skillName) || skillsManifest[skillName];
    if (!skill || !skill.path) {
      throw new Error(`Error: unknown skill "${skillName}"`);
    }
    copyDir(
      path.join(rootDir, skill.path),
      path.join(outputDir, '.agents', 'skills', skillName),
      placeholders
    );
  }

  const lock = {
    schemaVersion: 2,
    installedAt: new Date().toISOString(),
    source: 'github:kyeongsoo-yoo/agent-foundry',
    ref: getGitHead(rootDir),
    template: template || null,
    skills: installedSkills,
    externals: [],
  };
  fs.writeFileSync(path.join(outputDir, 'skills-lock.json'), JSON.stringify(lock, null, 2), 'utf8');

  console.log(`\n✓ agent-foundry init complete — ${projectName}`);
  console.log(`  template : ${template || '(none)'}`);
  console.log(`  skills   : ${installedSkills.join(', ')}`);
  if (template) console.log('\nNext: see NEXT_STEPS.md');
}

async function run(argv = process.argv.slice(2)) {
  const rootDir = path.join(__dirname, '..');
  if (isSubcommandMode(argv)) {
    return runSubcommand(argv, rootDir);
  }
  return runLegacy({ args: argv, rootDir });
}

module.exports = {
  run,
  runLegacy,
  runSubcommand,
};
