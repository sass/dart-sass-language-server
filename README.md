# Overview

This project is an early proof of concept of a language server for Sass written in Dart to make use of [sass_api](https://pub.dev/packages/sass_api). The proof of concept includes:

- Language server process with incremental document sync.
- User configuration.
- [Document links](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentLink) provider.
- Workspace scanner.
- VS Code client with debugging profile.

Check the documentation to get started:

- [Development environment](./docs/contributing/development-environment.md)
- [Debugging](./docs/contributing/debugging.md)
- [Building](./docs/contributing/building.md)
- [Architecture](./docs/contributing/architecture.md)
