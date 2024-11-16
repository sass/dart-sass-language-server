import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../position_utils.dart';
import '../../range_matchers.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('sass variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('global in the same document', () async {
      var document = fs.createDocument(r'''
$b: blue

.a
  color: $b

''', uri: 'styles.sass');
      var result = await ls.goToDefinition(document, at(line: 3, char: 10));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(0));
      expect(result.range, EndsAtCharacter(2));

      expect(result.uri.toString(), endsWith('styles.sass'));
    });

    test('global in a different document', () async {
      fs.createDocument(r'$b: #000;', uri: 'colors.scss');

      var document = fs.createDocument(r'''
@use "colors";

.a {
  color: $b;
}
''');
      var result = await ls.goToDefinition(document, at(line: 3, char: 10));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(0));
      expect(result.range, EndsAtLine(0));
      expect(result.range, StartsAtCharacter(0));
      expect(result.range, EndsAtCharacter(2));

      expect(result.uri.toString(), endsWith('colors.scss'));
    });

    test('scoped in the same document', () async {
      var document = fs.createDocument(r'''
.a
  $b: blue
  color: $b

''', uri: 'styles.sass');
      var result = await ls.goToDefinition(document, at(line: 2, char: 10));

      expect(result, isNotNull);
      expect(result!.range, StartsAtLine(1));
      expect(result.range, EndsAtLine(01));
      expect(result.range, StartsAtCharacter(2));
      expect(result.range, EndsAtCharacter(4));

      expect(result.uri.toString(), endsWith('styles.sass'));
    });

    test('no scoped in a different document', () async {
      fs.createDocument(r'''
.a
  $b: blue
  color: $b
''', uri: 'links.sass');

      var document = fs.createDocument(r'''
@use "links";

.a {
  color: $b;
}
''');
      var result = await ls.goToDefinition(document, at(line: 3, char: 10));

      expect(result, isNull);
    });
  });
}
