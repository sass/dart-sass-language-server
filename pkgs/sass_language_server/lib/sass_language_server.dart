/// The Sass language server.
///
/// Includes an executable `sass-language-server`. Run `sass-language-server --help` to see available options.
///
/// The server listens for incoming [JSON-RPC messages](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#languageServerProtocol). It handles [lifecycle messages](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#lifeCycleMessages) and [document synchronization](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#textDocument_synchronization) so the language server can keep track of the document and workspace state.
///
/// It has handlers for the different [language features](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#languageFeatures) and [workspace features](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.18/specification/#workspaceFeatures), but the implementation of those features are in `sass_language_services`.
library;

export 'src/local_file_system.dart' show LocalFileSystem;
export 'src/language_server.dart' show LanguageServer, Transport;
