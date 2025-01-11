# How to add new features

This document explains some of the steps involved in adding a new language- or workspace feature.

For some complete examples, see:

- [Folding ranges (#32)](https://github.com/sass/dart-sass-language-server/pull/32/files)
- [Workspace symbols (#26)](https://github.com/sass/dart-sass-language-server/pull/26/files)

A summary of what you need:

1. Extend [language_configuration.dart](../../pkgs/sass_language_services/lib/src/configuration/language_configuration.dart) to parse the user's configuration for the feature.
2. Set defaults for the same user configuration in [the extension's package.json](../../extension/package.json) (look for the `"configuration"` key, and check for existing options).
3. Declare that the language server has the new capability in [language_server.dart](../../pkgs/sass_language_server/lib/src/language_server.dart) (look for `ServerCapabilities`).
4. Add a request handler for the feature in `language_server.dart` using `_connection.on<FeatureName>`. If a method doesn't exist for the feature, use the generic `_connection.peer.registerMethod()`.
5. Create a folder for the feature in [sass_language_services](../../pkgs/sass_language_services/lib/src/features/).
6. Implement the feature in a class that extends `LanguageFeature`.
   - Look at existing features for some common patterns, such as how to parse a `TextDocument` to get the AST.
   - You may want to know what AST node is at a given `Position`. See `node_at_offset_visitor.dart`.
   - Use `findInWorkspace` to run a callback on each linked document, recursively (with a `lazy` option).
   - Write [tests](../../pkgs/sass_language_services/test/features/) using the [memory file system](../../pkgs/sass_language_services/test/memory_file_system.dart).
7. Add the feature to the public API in [language_services.dart](../../pkgs/sass_language_services/lib/src/language_services.dart).
8. Use the feature in the request handler in `language_server.dart`.
9. Add a VS Code test as an an end-to-end "smoketest" in the [extension](../../extension/test/README.md).
