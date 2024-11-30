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
 * @param {Array<import('vscode').Position>} positions
 * @returns {Promise<Array<import('vscode').SelectionRange>>}
 */
async function getSelectionRanges(documentUri, positions) {
  const result = await vscode.commands.executeCommand(
    'vscode.executeSelectionRangeProvider',
    documentUri,
    positions
  );
  return result;
}

test('gets document selection ranges', async () => {
  const [result] = await getSelectionRanges(stylesUri, [
    new vscode.Position(7, 5),
  ]);

  assert.ok(result, 'Should have gotten selection ranges');
});
