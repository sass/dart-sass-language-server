# Sass for Visual Studio Code

At the moment this extension is here only to test and debug the language server.
In the future this extension can act as an official VS Code client.

Outside of this repo the extension will need `sass-language-server` on your `PATH`. See [how to build from source](../docs/contributing/building.md). [Go for VS Code](https://github.com/golang/vscode-go/tree/master/extension) has a check for missing tools and an install helper, for inspiration down the line.

## Recommended settings

It's recommend you turn off the built-in CSS/SCSS/Less language extension to avoid conflicts and to test this extension in isolation.

1. Go to the Extensions tab and search for @builtin css language features.
2. Click the settings icon and pick Disable from the list.
3. Click Restart extension to turn it off.
