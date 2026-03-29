'use strict';

const fs = require('fs');
const path = require('path');

function loadCatalog(catalogPath) {
  const raw = fs.readFileSync(catalogPath, 'utf8');
  const catalog = JSON.parse(raw);

  if (!catalog || typeof catalog !== 'object') {
    throw new Error(`Invalid catalog: ${catalogPath}`);
  }

  catalog.skills = Array.isArray(catalog.skills) ? catalog.skills : [];
  catalog.docs = Array.isArray(catalog.docs) ? catalog.docs : [];

  return catalog;
}

function normalizeText(value) {
  return String(value || '').toLowerCase();
}

function matchesSource(skill, source) {
  if (source === 'all') return true;
  return skill.trust === source;
}

function matchesQuery(skill, query) {
  if (!query) return true;
  const normalizedQuery = normalizeText(query);
  return normalizeText(skill.name).includes(normalizedQuery) ||
    normalizeText(skill.description).includes(normalizedQuery);
}

function searchSkills({ catalog, query = '', source = 'curated' }) {
  if (!catalog || typeof catalog !== 'object') {
    throw new Error('searchSkills requires a catalog object');
  }

  if (!['curated', 'external', 'all'].includes(source)) {
    throw new Error(`Invalid skills source "${source}"`);
  }

  return (catalog.skills || []).filter((skill) => matchesSource(skill, source) && matchesQuery(skill, query));
}

function findCatalogSkill(catalog, skillName) {
  if (!catalog || typeof catalog !== 'object') {
    return null;
  }

  return (catalog.skills || []).find((skill) => skill.name === skillName) || null;
}

function catalogPathFromRoot(rootDir) {
  return path.join(rootDir, 'manifests', 'catalog.json');
}

module.exports = {
  catalogPathFromRoot,
  findCatalogSkill,
  loadCatalog,
  searchSkills,
};
