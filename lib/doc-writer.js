'use strict';

const fs = require('fs');
const path = require('path');

const { loadCatalog } = require('./catalog');
const { askConfirmation } = require('./prompt');

const TODO_MARKER = '<!-- TODO: project-specific details -->';

function resolveCatalogPath(projectRoot, toolRoot) {
  const projectCatalog = path.join(projectRoot, 'manifests', 'catalog.json');
  if (fs.existsSync(projectCatalog)) {
    return projectCatalog;
  }

  return path.join(toolRoot, 'manifests', 'catalog.json');
}

function findDocMapping(projectRoot, toolRoot, docType) {
  const catalog = loadCatalog(resolveCatalogPath(projectRoot, toolRoot));
  const { valid } = collectDocMappings(catalog.docs || []);
  const mapping = valid.find((doc) => doc.type === docType);
  if (!mapping) {
    const invalidMatch = (catalog.docs || []).find((doc) => doc && doc.type === docType);
    if (invalidMatch) {
      throw new Error(`Error: invalid doc mapping for type "${docType}"`);
    }
    throw new Error(`Error: unknown doc type "${docType}"`);
  }
  return mapping;
}

function resolveTemplatePath(projectRoot, toolRoot, mapping) {
  const projectTemplatePath = path.join(projectRoot, mapping.source);
  if (fs.existsSync(projectTemplatePath)) {
    return projectTemplatePath;
  }

  const toolTemplatePath = path.join(toolRoot, mapping.source);
  if (fs.existsSync(toolTemplatePath)) {
    return toolTemplatePath;
  }

  throw new Error(`Error: missing doc template "${mapping.source}"`);
}

function readTemplate(projectRoot, toolRoot, mapping) {
  const templatePath = resolveTemplatePath(projectRoot, toolRoot, mapping);
  return fs.readFileSync(templatePath, 'utf8');
}

function writeTarget(projectRoot, destination, content) {
  const targetPath = path.join(projectRoot, destination);
  fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  fs.writeFileSync(targetPath, content, 'utf8');
  return targetPath;
}

function suggestDocs({ projectRoot, toolRoot }) {
  const catalog = loadCatalog(resolveCatalogPath(projectRoot, toolRoot));
  const { valid, invalid } = collectDocMappings(catalog.docs || []);
  const missing = valid
    .filter((doc) => !fs.existsSync(path.join(projectRoot, doc.destination)))
    .map((doc) => ({
      type: doc.type,
      source: doc.source,
      destination: doc.destination,
      reason: 'missing file',
    }));

  return missing.concat(
    invalid.map((doc) => ({
      type: doc.type || '(unknown)',
      source: doc.source || '',
      destination: doc.destination || '',
      reason: 'invalid mapping',
    }))
  );
}

function formatDocSuggestions(suggestions) {
  if (suggestions.length === 0) {
    return 'All catalog docs are present.\n';
  }

  const lines = suggestions.map((doc) => `missing ${doc.destination} <- ${doc.source} (${doc.reason})`);
  return `${lines.join('\n')}\n`;
}

async function writeDoc({ projectRoot, toolRoot, docType, yes = false }) {
  const mapping = findDocMapping(projectRoot, toolRoot, docType);
  const template = readTemplate(projectRoot, toolRoot, mapping);

  if (!yes) {
    const confirmed = await askConfirmation(`Write ${mapping.destination} from ${mapping.source}?`);
    if (!confirmed) {
      return { destination: mapping.destination, targetPath: null, written: false };
    }
  }

  const content = `${template.trimEnd()}\n\n${TODO_MARKER}\n`;

  const targetPath = writeTarget(projectRoot, mapping.destination, content);
  return { destination: mapping.destination, targetPath, written: true };
}

function normalizeDocMapping(entry) {
  if (!entry || typeof entry !== 'object') return null;

  const type = typeof entry.type === 'string' ? entry.type.trim() : '';
  const source = typeof entry.source === 'string' ? entry.source.trim() : '';
  const destination = typeof entry.destination === 'string' ? entry.destination.trim() : '';

  if (!type || !source || !destination) return null;

  return { type, source, destination };
}

function collectDocMappings(entries) {
  const valid = [];
  const invalid = [];

  for (const entry of entries) {
    const normalized = normalizeDocMapping(entry);
    if (normalized) {
      valid.push(normalized);
    } else {
      invalid.push(entry || {});
    }
  }

  return { valid, invalid };
}

module.exports = {
  TODO_MARKER,
  collectDocMappings,
  formatDocSuggestions,
  suggestDocs,
  writeDoc,
  resolveTemplatePath,
};
