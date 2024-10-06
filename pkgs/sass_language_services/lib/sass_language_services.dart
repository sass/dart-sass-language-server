/// The Sass language server features.
///
/// For a language where Sass is embedded you can use this library
/// if your language server is also written in Dart. Otherwise you may
/// want to use [the request forwarding pattern](https://code.visualstudio.com/api/language-extensions/embedded-languages#request-forwarding)
/// in your languages' client.
library;

export 'src/sass_language_services_base.dart';
export 'src/file_system.dart';
