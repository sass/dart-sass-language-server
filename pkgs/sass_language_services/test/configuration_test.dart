import 'package:test/test.dart';

import 'package:sass_language_services/src/configuration/configuration.dart';

void main() {
  group('EditorConfiguration', () {
    test('default configuration is as expected', () {
      var result = LanguageServerConfiguration.from(null);

      expect(result.editor.colorDecoratorsLimit, 500);
      expect(result.editor.indentSize, 2);
      expect(result.editor.insertSpaces, false);
      expect(result.editor.locale, "en_US");
    });

    test('can override default settings with user settings', () {
      var result = LanguageServerConfiguration.from({
        "editor": {"insertSpaces": true}
      });

      expect(result.editor.insertSpaces, true);

      // else defaults
      expect(result.editor.colorDecoratorsLimit, 500);
      expect(result.editor.indentSize, 2);
      expect(result.editor.locale, "en_US");
    });
  });

  group('WorkspaceConfiguration', () {
    test('default configuration is as expected', () {
      var result = LanguageServerConfiguration.from(null);

      expect(result.workspace.exclude,
          equals(["**/.git/**", "**/node_modules/**"]));

      expect(result.workspace.loadPaths.isEmpty, true);
      expect(result.workspace.importAliases.isEmpty, true);
    });

    test('can override default settings with user settings', () {
      var result = LanguageServerConfiguration.from({
        "workspace": {
          "loadPaths": ["shared/"]
        }
      });

      expect(result.workspace.loadPaths, equals(["shared/"]));

      // else defaults

      expect(result.workspace.exclude,
          equals(["**/.git/**", "**/node_modules/**"]));
      expect(result.workspace.importAliases.isEmpty, true);
    });
  });
}
