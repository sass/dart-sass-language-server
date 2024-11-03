const path = require('node:path');
const fs = require('node:fs/promises');
const {
  runTests,
  downloadAndUnzipVSCode,
  resolveCliArgsFromVSCodeExecutablePath,
} = require('@vscode/test-electron');

async function main() {
  try {
    // The folder containing the Extension Manifest package.json
    // Passed to `--extensionDevelopmentPath`
    const extensionDevelopmentPath = path.resolve(__dirname, '..', '..');

    const version = 'insiders';

    // Download VS Code, unzip it and run the integration test
    const vscodeExecutablePath = await downloadAndUnzipVSCode(version);

    const [cli, ...args] =
      resolveCliArgsFromVSCodeExecutablePath(vscodeExecutablePath);

    if (!cli) {
      throw new Error(
        'Something went wrong resolving the CLI path to the download of VS Code'
      );
    }

    // For each folder, run the tests in index.js with that folder's fixtures/
    // as the workspace directory.
    const dir = await fs.readdir(__dirname, { withFileTypes: true });
    for (let entry of dir) {
      if (entry.isDirectory()) {
        // The path to the extension test script
        // Passed to --extensionTestsPath
        const extensionTestsPath = path.resolve(
          entry.parentPath,
          entry.name,
          'index.js'
        );

        const workspaceDir = path.resolve(
          entry.parentPath,
          entry.name,
          'fixtures'
        );

        await runTests({
          vscodeExecutablePath,
          version,
          extensionDevelopmentPath,
          extensionTestsPath,
          launchArgs: [
            workspaceDir,
            ...args,
            // Turn off the built-in language server to
            // make sure we're testing our own.
            '--disable-extension',
            'vscode.css-language-features',
          ],
        });
      }
    }
  } catch (error) {
    console.error('Failed to run tests');
    console.error(error.name);
    console.error(error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

main();