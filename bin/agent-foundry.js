#!/usr/bin/env node
// bin/agent-foundry.js — agent-foundry CLI
// Node 18+ built-in only: fs, path, process
'use strict';

const { run } = require('../lib/cli');

try {
  run(process.argv.slice(2));
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
