const assert = require('node:assert');
const path = require('node:path');
const vscode = require('vscode');
const { showFile, sleepCI } = require('../util');

const stylesUri = vscode.Uri.file(
  path.resolve(__dirname, 'fixtures', 'styles.scss')
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
 * @param {import('vscode').Position} position
 * @returns {Promise<{ range: import('vscode').Range, placeholder: string }>}
 */
async function prepareRename(documentUri, position) {
  const result = await vscode.commands.executeCommand(
    'vscode.prepareRename',
    documentUri,
    position
  );
  return result;
}

/**
 * @param {import('vscode').Uri} documentUri
 * @param {import('vscode').Position} position
 * @param {string} newName
 * @returns {Promise<import('vscode').WorkspaceEdit>}
 */
async function rename(documentUri, position, newName) {
  const result = await vscode.commands.executeCommand(
    'vscode.executeDocumentRenameProvider',
    documentUri,
    position,
    newName
  );
  return result;
}

test('renames symbol across workspace', async () => {
  const preparation = await prepareRename(
    stylesUri,
    new vscode.Position(3, 20)
  );

  assert.ok(preparation, 'Should have a result from prepare rename');
  assert.equal(preparation.placeholder, 'color-primary');

  const result = await rename(
    stylesUri,
    preparation.range.start,
    'color-secondary'
  );
  assert.ok(result, 'Should have returned a workspace edit response');
  assert.equal(result.entries().length, 3);
});
