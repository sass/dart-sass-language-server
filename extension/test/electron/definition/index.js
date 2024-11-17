const path = require('node:path');
const fs = require('node:fs/promises');
const vscode = require('vscode');
const { runMocha } = require('../mocha');

/**
 * @returns {Promise<void>}
 */
async function run() {
  const filePaths = [];

  const dir = await fs.readdir(__dirname, { withFileTypes: true });
  for (let entry of dir) {
    if (entry.isFile() && entry.name.endsWith('test.js')) {
      filePaths.push(path.join(entry.parentPath, entry.name));
    }
  }

  await runMocha(
    filePaths,
    vscode.Uri.file(path.resolve(__dirname, 'fixtures', 'styles.scss'))
  );
}

module.exports = { run };
