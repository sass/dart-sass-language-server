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
 * @returns {Promise<Array<import('vscode').DocumentHighlight>>}
 */
async function getHighlights(documentUri, position) {
  const result = await vscode.commands.executeCommand(
    'vscode.executeDocumentHighlights',
    documentUri,
    position
  );
  return result;
}

test('gets document highlights', async () => {
  const [first, second] = await getHighlights(
    stylesUri,
    new vscode.Position(7, 5)
  );

  assert.ok(first, 'Should have found highlights');
  assert.ok(second, 'Should have found two highlights');

  assert.equal(first.range.start.line, 7);
  assert.equal(first.range.start.character, 2);

  assert.equal(first.range.end.line, 7);
  assert.equal(first.range.end.character, 14);

  assert.equal(second.range.start.line, 11);
  assert.equal(second.range.start.character, 13);

  assert.equal(second.range.end.line, 11);
  assert.equal(second.range.end.character, 25);
});
