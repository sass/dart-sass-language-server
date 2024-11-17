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
 * @returns {Promise<Array<import('vscode').Location>>}
 */
async function goToDefinition(documentUri, position) {
  const result = await vscode.commands.executeCommand(
    'vscode.executeDefinitionProvider',
    documentUri,
    position
  );
  return result;
}

test('gets document symbols', async () => {
  const [result] = await goToDefinition(stylesUri, new vscode.Position(3, 12));

  assert.ok(result, 'Should have found the definition for %brand');
  assert.match(result.uri.toString(), /_theme\.sass$/);

  assert.equal(result.range.start.line, 0);
  assert.equal(result.range.start.character, 0);

  assert.equal(result.range.end.line, 0);
  assert.equal(result.range.end.character, 6);
});
