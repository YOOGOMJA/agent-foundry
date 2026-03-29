'use strict';

const fs = require('fs');
const path = require('path');

const { loadCatalog } = require('./catalog');
const { collectDocMappings } = require('./doc-writer');

function resolveCatalogPath(projectRoot, toolRoot) {
  const projectCatalog = path.join(projectRoot, 'manifests', 'catalog.json');
  if (fs.existsSync(projectCatalog)) {
    return projectCatalog;
  }

  return path.join(toolRoot, 'manifests', 'catalog.json');
}

function buildCheck(id, status, message) {
  return { id, status, message };
}

function missingDocs(projectRoot, catalog) {
  const { valid } = collectDocMappings(catalog.docs || []);
  return valid.filter((doc) => !fs.existsSync(path.join(projectRoot, doc.destination)));
}

function runAudit({ projectRoot, toolRoot }) {
  const catalog = loadCatalog(resolveCatalogPath(projectRoot, toolRoot));
  const checks = [];
  const { invalid } = collectDocMappings(catalog.docs || []);

  const docsShapeValid = invalid.length === 0;
  checks.push(
    buildCheck(
      'catalog-docs-shape',
      docsShapeValid ? 'PASS' : 'FAIL',
      docsShapeValid
        ? 'catalog docs mappings are valid'
        : `catalog docs mappings are invalid (${invalid.length} malformed)`
    )
  );

  const missing = missingDocs(projectRoot, catalog);
  checks.push(
    buildCheck(
      'docs-missing',
      missing.length === 0 ? 'PASS' : 'WARN',
      missing.length === 0
        ? 'all catalog docs exist'
        : `missing docs: ${missing.map((doc) => doc.destination).join(', ')}`
    )
  );

  const lockPath = path.join(projectRoot, 'skills-lock.json');
  checks.push(
    buildCheck(
      'skills-lock',
      fs.existsSync(lockPath) ? 'PASS' : 'WARN',
      fs.existsSync(lockPath) ? 'skills-lock.json exists' : 'skills-lock.json not found'
    )
  );

  const status = checks.some((check) => check.status === 'FAIL')
    ? 'FAIL'
    : checks.some((check) => check.status === 'WARN')
      ? 'WARN'
      : 'PASS';

  return { status, checks };
}

function formatAuditText(result) {
  const lines = [`status: ${result.status}`];
  for (const check of result.checks) {
    lines.push(`${check.status} ${check.id}: ${check.message}`);
  }
  return `${lines.join('\n')}\n`;
}

module.exports = {
  formatAuditText,
  runAudit,
};
