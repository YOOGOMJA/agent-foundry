'use strict';

const readline = require('readline');

function askConfirmation(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(`${question} [y/N] `, (answer) => {
      rl.close();
      resolve(/^y(es)?$/i.test(String(answer || '').trim()));
    });
    rl.on('close', () => {
      resolve(false);
    });
  });
}

module.exports = {
  askConfirmation,
};
