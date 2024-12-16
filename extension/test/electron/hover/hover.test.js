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
 * @param {import('vscode').Hover[]} hover
 * @returns {string}
 */
function getHoverContents(hover) {
  return hover
    .flatMap((item) => {
      return item.contents.map((content) =>
        typeof content === 'string' ? content : content.value
      );
    })
    .join('\n');
}

/**
 * @param {import('vscode').Uri} documentUri
 * @param {import('vscode').Position} position
 * @returns {Promise<import('vscode').Hover[]>}
 */
async function hover(documentUri, position) {
  const result = await vscode.commands.executeCommand(
    'vscode.executeHoverProvider',
    documentUri,
    position
  );
  return result;
}

test('gets hover information from the same document', async () => {
  const result = await hover(stylesUri, new vscode.Position(7, 10));

  assert.match(
    getHoverContents(result),
    /\.card \.body:has\(:not\(\.stuff\)\)/
  );
});

test('gets hover information from the workspace', async () => {
  const result = await hover(stylesUri, new vscode.Position(4, 19));

  assert.match(getHoverContents(result), /Docstring/);
});

test('gets hover information for Sass built-in', async () => {
  const result = await hover(stylesUri, new vscode.Position(3, 14));

  assert.match(
    getHoverContents(result),
    /Returns a randomly-generated unquoted string/
  );
});
