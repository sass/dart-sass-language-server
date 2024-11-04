import 'package:test/test.dart';

import 'package:sass_language_services/src/configuration/configuration.dart';

void main() {
  group('EditorConfiguration', () {
    test('default configuration is as expected', () {
      var result = LanguageServerConfiguration.create(null);

      expect(result.editor.colorDecoratorsLimit, equals(500));
      expect(result.editor.indentSize, equals(2));
      expect(result.editor.insertSpaces, isFalse);
    });

    test('can override default settings with user settings', () {
      var result = LanguageServerConfiguration.create({
        "editor": {"insertSpaces": true}
      });

      expect(result.editor.insertSpaces, isTrue);

      // else defaults
      expect(result.editor.colorDecoratorsLimit, equals(500));
      expect(result.editor.indentSize, equals(2));
    });
  });

  group('WorkspaceConfiguration', () {
    test('default configuration is as expected', () {
      var result = LanguageServerConfiguration.create(null);

      expect(result.workspace.exclude,
          equals(["**/.git/**", "**/node_modules/**"]));

      expect(result.workspace.loadPaths, isEmpty);
      expect(result.workspace.importAliases, isEmpty);
    });

    test('can override default settings with user settings', () {
      var result = LanguageServerConfiguration.create({
        "sass": {
          "workspace": {
            "loadPaths": ["shared/"]
          }
        }
      });

      expect(result.workspace.loadPaths, equals(["shared/"]));

      // else defaults

      expect(result.workspace.exclude,
          equals(["**/.git/**", "**/node_modules/**"]));
      expect(result.workspace.importAliases, isEmpty);
    });
  });
}
