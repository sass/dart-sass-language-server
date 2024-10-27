/// The Sass language server features.
///
/// For a language where Sass is embedded you can use this library
/// if your language server is also written in Dart. Otherwise you may
/// want to use [the request forwarding pattern](https://code.visualstudio.com/api/language-extensions/embedded-languages#request-forwarding)
/// in your languages' client.
library;

export 'src/configuration/configuration.dart' show LanguageServerConfiguration;
export 'src/configuration/editor_configuration.dart' show EditorConfiguration;
export 'src/configuration/language_configuration.dart'
    show LanguageConfiguration;
export 'src/configuration/workspace_configuration.dart'
    show WorkspaceConfiguration;

export 'src/lsp/text_document.dart' show TextDocument;

export 'src/file_system_provider.dart'
    show FileSystemProvider, ProviderFileStat, ProviderEntryType;

export 'src/language_services.dart' show LanguageServices;
