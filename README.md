# Overview

This is a work-in-progress language server for Sass written in Dart to
use [sass_api](https://pub.dev/packages/sass_api).
It uses [the language server protocol](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#languageFeatures) (LSP).

## Status

[Development of new features is paused](https://github.com/sass/dart-sass/issues/2476). See the Issues and Pull request tabs for planned and partially implemented features.

The [Testing and debugging](docs/contributing/testing-and-debugging.md) docs explain how to run the language server from source code.

These features are implemented:

| Feature                                                                                  | Specification                                                                                                                                                                                                                                                                                |
| ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Document highlights](pkgs/sass_language_services/lib/src/features/document_highlights/) | [textDocument/documentHighlight](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_documentHighlight)                                                                                                                                 |
| [Document links](pkgs/sass_language_services/lib/src/features/document_links/)           | [textDocument/documentLink](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_documentLink)                                                                                                                                           |
| [Document symbols](pkgs/sass_language_services/lib/src/features/document_symbols/)       | [textDocument/documentSymbol](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_documentSymbol)                                                                                                                                       |
| [Find references](pkgs/sass_language_services/lib/src/features/find_references/)         | [textDocument/references](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_references)                                                                                                                                               |
| [Folding ranges](pkgs/sass_language_services/lib/src/features/folding_ranges/)           | [textDocument/foldingRange](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_foldingRange)                                                                                                                                           |
| [Go to definition](pkgs/sass_language_services/lib/src/features/go_to_definition/)       | [textDocument/definition](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_definition)                                                                                                                                               |
| [Hover](pkgs/sass_language_services/lib/src/features/hover/)                             | [textDocument/hover](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_hover)                                                                                                                                                         |
| [Rename](pkgs/sass_language_services/lib/src/features/rename/)                           | [textDocument/prepareRename](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_prepareRename), [textDocument/rename](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_rename) |
| [Selection ranges](pkgs/sass_language_services/lib/src/features/selection_ranges/)       | [textDocument/selectionRange](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_selectionRange)                                                                                                                                       |
| [Workspace symbol](pkgs/sass_language_services/lib/src/features/workspace_symbols/)      | [workspace/symbol](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#workspace_symbol)                                                                                                                                                             |

## How to contribute

See [Contributing](./CONTRIBUTING.md), but note that the parser currently requires a valid Sass document to generate an AST ([sass/dart-sass#2476](https://github.com/sass/dart-sass/issues/2476)).
