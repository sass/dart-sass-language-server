const assert = require('node:assert');
const path = require('node:path');
const vscode = require('vscode');
const { showFile, sleepCI } = require('../util');

const stylesUri = vscode.Uri.file(
  path.resolve(__dirname, 'fixtures', 'styles.scss')
);
const circularUri = vscode.Uri.file(
  path.resolve(__dirname, 'fixtures', 'circular.scss')
);

before(async () => {
  await showFile(stylesUri);
  await showFile(circularUri);
  await sleepCI();
});

after(async () => {
  await vscode.commands.executeCommand('workbench.action.closeAllEditors');
});

/**
 * @param {import('vscode').Uri} documentUri
 * @returns {Promise<import('vscode').DocumentLink[]>}
 */
async function findDocumentLinks(documentUri) {
  const links = await vscode.commands.executeCommand(
    'vscode.executeLinkProvider',
    documentUri
  );
  return links;
}

/**
 * @param {import('vscode').Uri} uri
 * @returns {Promise<void>}
 */
async function goToTarget(uri) {
  await vscode.commands.executeCommand('vscode.open', uri);
}

test('navigating to a circular dependency does not cause a loop', async () => {
  await showFile(stylesUri);
  let links = await findDocumentLinks(stylesUri);

  const circular = links.find(
    (v) => v.target && v.target.path.endsWith('circular.scss')
  );
  if (!circular || !circular.target) {
    return assert.fail('Did not find a working link to circular.scss');
  }

  await goToTarget(circular.target);

  assert.equal(
    vscode.window.activeTextEditor?.document.uri.fsPath,
    circularUri.fsPath,
    'Should be viewing circular.scss right now'
  );

  links = await findDocumentLinks(circular.target);
  const styles = links.find(
    (v) => v.target && v.target.path.endsWith('styles.scss')
  );
  if (!styles || !styles.target) {
    return assert.fail('Did not find a working link to styles.scss');
  }

  await goToTarget(styles.target);

  assert.equal(
    vscode.window.activeTextEditor?.document.uri.fsPath,
    stylesUri.fsPath,
    'Should be viewing styles.scss right now'
  );
});
