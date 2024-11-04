import 'package:test/test.dart';
import 'package:sass_language_server/src/utils/uri.dart';

void main() {
  group('Uri utils', () {
    test('root path to URI', () {
      expect(
          filePathToUri(
              "c:\\workspace\\dart-sass-language-server\\extension\\test\\electron\\document-links\\fixtures"),
          equals(Uri.parse(
              "file:///c:/workspace/dart-sass-language-server/extension/test/electron/document-links/fixtures")));
    });
  });
}
