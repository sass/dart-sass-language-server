const vscode = require('vscode');

/**
 * @param {number} ms
 * @returns {Promise<void>}
 */
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * @param {import('vscode').Uri} docUri
 * @returns {Promise<import('vscode').TextEditor>}
 */
async function showFile(docUri) {
  const doc = await vscode.workspace.openTextDocument(docUri);
  return vscode.window.showTextDocument(doc);
}

/**
 * @param {number} ms
 * @returns {Promise<void>}
 */
async function sleepCI(ms = 2000) {
  if (process.env['CI']) {
    await sleep(ms);
    return;
  }

  await sleep(0);
}

/**
 * @private
 * @param {import('vscode').TextDocument} doc
 * @returns {Promise<import('vscode').TextDocument>}
 */
function onDocumentChange(doc) {
  return new Promise((resolve) => {
    const sub = vscode.workspace.onDidChangeTextDocument((e) => {
      if (e.document !== doc) {
        return;
      }
      sub.dispose();
      resolve(e.document);
    });
  });
}

/**
 * Emulate a user typing in one character at a time.
 *
 * @param {import('vscode').TextEditor} editor
 * @param {string} text
 * @returns {Promise<import('vscode').TextEditor>}
 */
async function type(editor, text) {
  const document = editor.document;
  const onChange = onDocumentChange(document);
  for (let char of text) {
    await vscode.commands.executeCommand('type', { text: char });
    await onChange;
  }
  return editor;
}

module.exports = {
  sleep,
  sleepCI,
  showFile,
  type,
};
