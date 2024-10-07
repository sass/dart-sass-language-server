/// The Sass language server features.
///
/// For a language where Sass is embedded you can use this library
/// if your language server is also written in Dart. Otherwise you may
/// want to use [the request forwarding pattern](https://code.visualstudio.com/api/language-extensions/embedded-languages#request-forwarding)
/// in your languages' client.
library;

export 'src/language_services_base.dart';

export 'src/configuration/configuration.dart';
export 'src/configuration/editor_configuration.dart';
export 'src/configuration/language_configuration.dart'
    show LanguageConfiguration;
export 'src/configuration/workspace_configuration.dart';

export 'src/file_system_provider.dart';
