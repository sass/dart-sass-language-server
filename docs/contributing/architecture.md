# Architecture

The Sass language server uses the [language server protocol](https://microsoft.github.io/language-server-protocol/) (LSP). With LSP one language server can be used in any editor that has a language client which supports the language server protocol.

This repository has a language client for [Visual Studio Code](https://code.visualstudio.com/) in the [extension](../../extension/) directory.

The language server is divided in two packages:

- [sass_language_server](./pkgs/sass_language_server/)
- [sass_language_services](./pkgs/sass_language_services/)

We have this split so the language server features are reusable [for embedded languages](https://code.visualstudio.com/api/language-extensions/embedded-languages) where the embedder language server is also written in Dart.

## sass_language_server

This is the language server executable. Users will install this package, and the language client will run the server when needed.

## sass_language_services

This is where you find the core functionality of the language server. Individual features are in the `lib/src/features/` directory. Each feature extends a base `LanguageFeature` class.

When used, all features parse the given [`TextDocumentItem`](https://pub.dev/documentation/lsp_server/latest/lsp_server/TextDocumentItem-class.html) using [`sass_api`](https://pub.dev/packages/sass_api) to get the [`Stylesheet` node](https://pub.dev/documentation/sass_api/latest/sass/Stylesheet-class.html). Parses are cached, along with other often-used information such as resolved links.

## extension

This is the [language extension](https://code.visualstudio.com/api/language-extensions/overview) (containing the language client) for Visual Studio Code. The extension is set up to create one language client (and so run one language server) per [workspace](https://code.visualstudio.com/docs/editor/multi-root-workspaces).

The language client uses the Socket transport to communicate with the language server. Perhaps confusingly, [it is the language client which is the socket server](https://github.com/microsoft/vscode-languageserver-node/issues/245#issuecomment-336054699). The language server then connects to the socket server that is running on the client.

If you are configuring a client for another editor you may want to use the `--stdio` transport for ease of use. We use sockets in the Visual Studio Code extension since Dart's debug mode prints to stdout, which interferes with the language server output.
