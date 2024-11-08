# Testing the VS Code extension

These tests automate Visual Studio Code using the [VS Code JavaScript API](https://code.visualstudio.com/api/references/vscode-api).
See [the list of built-in commands](https://code.visualstudio.com/api/references/commands#commands) to see how you can automate the interactions you need for testing.

There are two different test runners available:

- [@vscode/test-electron](https://github.com/microsoft/vscode-test)
- [@vscode/test-web](https://github.com/microsoft/vscode-test-web)

We only test using Electron.

The Electron runner is configured so it can run multiple instances of VS Code (in sequence) using
different configurations and workspaces. Each subdirectory in `electron/` will run in a separate instance
of VS Code.

By convention subdirectories in `e2e/` must have:

- `index.js` as the entrypoint that finds test files and passes them to Mocha
- at least one `*.test.js` file with some tests
- a `fixtures/` subdirectory with:
  - `.vscode/settings.json`
  - `styles.scss` or `styles.sass`

Starting and stopping VS Code takes a few seconds, so try to use the same workspaces as much as possible.
