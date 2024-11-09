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

    test('should collect CSS class selectors', () {
      var document = fs.createDocument('''
.foo {
  color: red;
}

.bar {
  color: blue;
}
''');

      var result = ls.findDocumentSymbols(document);
      expect(result.length, equals(2));

      expect(result.first.name, equals(".foo"));
      expect(result.last.name, equals(".bar"));
    });

    test('should treat CSS selectors with multiple classes as one', () {
      var document = fs.createDocument('''
.foo.bar {
  color: red;
}

.fizz .buzz {
  color: blue;
}
''');

      var result = ls.findDocumentSymbols(document);
      expect(result.length, equals(2));

      expect(result.first.name, equals(".foo.bar"));
      expect(result.last.name, equals(".fizz .buzz"));
    });

    test('should treat lists of selectors as separate', () {
      var document = fs.createDocument('''
.foo.bar,
.fizz .buzz {
  color: red;
}
''');

      var result = ls.findDocumentSymbols(document);
      expect(result.length, equals(2));

      expect(result.first.name, equals(".foo.bar"));
      expect(result.last.name, equals(".fizz .buzz"));
    });

    test('should include extras', () {
      var document = fs.createDocument('''
.foo:has([data-testid="bar"]) {
  color: red;
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.first.name, equals('.foo:has([data-testid="bar"])'));
    });

    test('placeholder selectors', () {
      var document = fs.createDocument('''
%waitforit {
  color: red;
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.first.name, equals('%waitforit'));
    });
  });

  group('variables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('CSS variables', () {
      var document = fs.createDocument('''
.hello {
  --world: blue;
  color: var(--world);
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.length, equals(1));
      expect(result.first.name, equals('.hello'));

      expect(result.first.children!.length, equals(1));
      expect(result.first.children!.first.name, equals('--world'));
    });

    test('public variables', () {
      var document = fs.createDocument(r'''
$world: blue;
.hello {
  color: $world;
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.first.name, equals(r'$world'));
    });
  });

  group('callables', () {
    setUp(() {
      ls.cache.clear();
    });

    test('functions', () {
      var document = fs.createDocument(r'''
@function doStuff($a: 1, $b: 2) {
  $value: $a + $b;
  @return $value;
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.length, equals(1));
      expect(result.first.name, equals('doStuff'));

      expect(result.first.children!.length, equals(1));
      expect(result.first.children!.first.name, equals(r'$value'));
    });

    test('mixins', () {
      var document = fs.createDocument(r'''
@mixin mixin1 {
  $value: 1;
  line-height: $value;
}
''');
      var result = ls.findDocumentSymbols(document);

      expect(result.length, equals(1));
      expect(result.first.name, equals(r'mixin1'));

      expect(result.first.children!.length, equals(1));
      expect(result.first.children!.first.name, equals(r'$value'));
    });
  });

  group('at-rules', () {
    setUp(() {
      ls.cache.clear();
    });

    test('@media', () {
      var document = fs.createDocument(r'''
@media screen, print {
  body {
    font-size: 14pt;
  }
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.length, equals(1));
      expect(result.first.name, equals('@media screen, print'));

      expect(result.first.children!.length, equals(1));
      expect(result.first.children!.first.name, equals('body'));
    });

    test('@font-face', () {
      var document = fs.createDocument(r'''
@font-face {
  font-family: "Vulf Mono", monospace;
}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.first.name, equals('font-face'));
    });

    test('@keyframes', () {
      var document = fs.createDocument(r'''
@keyframes animation {

}
''');
      var result = ls.findDocumentSymbols(document);
      expect(result.first.name, equals('animation'));
    });
  });
}
