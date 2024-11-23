import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/go_to_definition/scope.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('scope', () {
    setUp(() {
      ls.cache.clear();
    });

    test('relationship between scopes', () {
      var global = Scope(offset: 0, length: double.maxFinite.floor());
      var first = Scope(offset: 10, length: 5);
      var second = Scope(offset: 15, length: 5);

      global.addChild(first);
      global.addChild(second);

      expect(global.children, hasLength(2));

      expect(first.parent, equals(global));
      expect(second.parent, equals(global));
    });

    test('findScope', () {
      var global = Scope(offset: 0, length: double.maxFinite.floor());
      var first = Scope(offset: 10, length: 5);
      var second = Scope(offset: 15, length: 5);

      global.addChild(first);
      global.addChild(second);

      expect(global.findScope(offset: -1), isNull);

      expect(global.findScope(offset: 0), equals(global));
      expect(global.findScope(offset: 21), equals(global));

      expect(global.findScope(offset: 10), equals(first));
      expect(global.findScope(offset: 14), equals(first));
      expect(global.findScope(offset: 15), equals(second));
      expect(global.findScope(offset: 20), equals(second));
    });
  });
}
