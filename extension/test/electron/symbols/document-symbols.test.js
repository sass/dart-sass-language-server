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
 * @param {import('vscode').Uri} documentUri
 * @returns {Promise<import('vscode').DocumentSymbol[]>}
 */
async function findDocumentSymbols(documentUri) {
  const result = await vscode.commands.executeCommand(
    'vscode.executeDocumentSymbolProvider',
    documentUri
  );
  return result;
}

test('gets document symbols', async () => {
  const result = await findDocumentSymbols(stylesUri);

  assert.ok(
    result.find((s) => s.name === '.card .body:has(:not(.stuff))'),
    'Should have found .card .body:has(:not(.stuff))'
  );
});
