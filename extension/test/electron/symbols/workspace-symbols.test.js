const assert = require('node:assert');
const path = require('node:path');
const vscode = require('vscode');
const { showFile, sleepCI } = require('../util');

const stylesUri = vscode.Uri.file(
  path.resolve(__dirname, 'fixtures', 'styles.sass')
);

before(async () => {
  await showFile(stylesUri);
  await sleepCI();
});

after(async () => {
  await vscode.commands.executeCommand('workbench.action.closeAllEditors');
});

/**
 * @param {string} [query='']
 * @returns {Promise<import('vscode').SymbolInformation[]>}
 */
async function findWorkspaceSymbols(query = '') {
  const result = await vscode.commands.executeCommand(
    'vscode.executeWorkspaceSymbolProvider',
    query
  );
  return result;
}

test('gets workspace symbols with empty query', async () => {
  const result = await findWorkspaceSymbols();

  assert.ok(result.find((s) => s.name === '.hello'));
  assert.ok(result.find((s) => s.name === '$from-other'));
});

test('gets workspace symbols with query', async () => {
  const result = await findWorkspaceSymbols('other');

  assert.equal(
    result.find((s) => s.name === '.hello'),
    undefined
  );

  assert.ok(result.find((s) => s.name === '$from-other'));
});
