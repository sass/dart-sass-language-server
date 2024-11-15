import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());
void main() {
  group('selectors', () {
    setUp(() {
      ls.cache.clear();
    });


  });
}
