import 'package:test/test.dart';

import 'package:sass_language_services/src/utils/node_utils.dart';

void main() {
  group('getModuleNameFromPath', () {
    test('returns the input if there is no slash', () {
      var result = getModuleNameFromPath('path');
      expect(result, equals('path'));
    });

    test('returns the input up to the first slash', () {
      var result = getModuleNameFromPath('path/to/foo');
      expect(result, equals('path'));
    });

    test('returns an empty string if the input is an absolute path', () {
      var result = getModuleNameFromPath('/path/to/foo');
      expect(result, isEmpty);
    });

    test('handles scoped npm modules (ex. @foo/bar)', () {
      var result = getModuleNameFromPath('@foo/bar');
      expect(result, equals('@foo/bar'));
    });

    test(
        'returns only the scoped module name in case of subpaths (ex. @foo/bar/baz)',
        () {
      var result = getModuleNameFromPath('@foo/bar/baz');
      expect(result, equals('@foo/bar'));
    });
  });
}
