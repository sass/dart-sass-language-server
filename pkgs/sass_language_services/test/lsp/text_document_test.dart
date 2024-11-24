import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../position_utils.dart';

TextDocument createDocument(String content) {
  return TextDocument(Uri.parse('test://hello/world'), 'text', 0, content);
}

lsp.Either2<lsp.TextDocumentContentChangeEvent1,
    lsp.TextDocumentContentChangeEvent2> updateFull(String text) {
  return lsp.Either2.t2(lsp.TextDocumentContentChangeEvent2(text: text));
}

lsp.Either2<lsp.TextDocumentContentChangeEvent1,
        lsp.TextDocumentContentChangeEvent2>
    updateIncremental(String text, lsp.Range range) {
  return lsp.Either2.t2(lsp.TextDocumentContentChangeEvent2(text: text));
}

lsp.Range forSubstring(TextDocument document, String substring) {
  var i = document.getText().indexOf(substring);
  return lsp.Range(
    start: document.positionAt(i),
    end: document.positionAt(i + substring.length),
  );
}

lsp.Range afterSubstring(TextDocument document, String substring) {
  var i = document.getText().indexOf(substring);
  var pos = document.positionAt(i);
  return lsp.Range(start: pos, end: pos);
}

lsp.TextEdit insert(String text, lsp.Position at) {
  return lsp.TextEdit(newText: text, range: lsp.Range(start: at, end: at));
}

lsp.TextEdit replace(String text, lsp.Range range) {
  return lsp.TextEdit(newText: text, range: range);
}

lsp.TextEdit delete(lsp.Range range) {
  return lsp.TextEdit(newText: '', range: range);
}

void main() {
  group('lines, offsets and positions', () {
    test('empty content', () {
      var document = createDocument('');

      expect(document.lineCount, equals(1));
      expect(document.offsetAt(position(0, 0)), equals(0));

      var pos = document.positionAt(0);
      expect(pos.line, equals(0));
      expect(pos.character, equals(0));
    });

    test('single line', () {
      var content = 'Hello World';
      var document = createDocument(content);
      expect(document.lineCount, equals(1));

      for (var i = 0; i < content.length; i++) {
        expect(document.offsetAt(position(0, i)), equals(i));
        var pos = document.positionAt(i);
        expect(pos.line, equals(0));
        expect(pos.character, equals(i));
      }
    });

    test('multiple lines', () {
      var content = '''abcde
fghij
klmno
''';
      var document = createDocument(content);
      expect(document.lineCount, equals(4));

      for (var i = 0; i < content.length; i++) {
        var line = (i / 6).floor();
        var char = i % 6;
        expect(document.offsetAt(position(line, char)), equals(i));

        var pos = document.positionAt(i);
        expect(pos.line, equals(line));
        expect(pos.character, equals(char));
      }

      // Out of bounds.
      expect(document.offsetAt(position(3, 0)), content.length);
      expect(document.offsetAt(position(3, 1)), content.length);

      var pos = document.positionAt(18);
      expect(pos.line, equals(3));
      expect(pos.character, equals(0));

      pos = document.positionAt(19);
      expect(pos.line, equals(3));
      expect(pos.character, equals(0));
    });

    test('starts with newline', () {
      var content = '\nABCDE';
      var document = createDocument(content);
      expect(document.lineCount, equals(2));
    });

    test('newline characters', () {
      var document = createDocument('\rABCDE');
      expect(document.lineCount, equals(2));
      document = createDocument('\nABCDE');
      expect(document.lineCount, equals(2));

      document = createDocument('\r\nABCDE');
      expect(document.lineCount, equals(2));

      document = createDocument('\n\nABCDE');
      expect(document.lineCount, equals(3));

      document = createDocument('\r\rABCDE');
      expect(document.lineCount, equals(3));

      document = createDocument('\n\rABCDE');
      expect(document.lineCount, equals(3));
    });

    test('getText', () {
      var content = 'abcde\nfghij\nklmno';
      var document = createDocument(content);
      expect(document.getText(), equals(content));

      expect(
        document.getText(range: range(0, 0, 0, 5)),
        equals('asdf'),
      );
      expect(
        document.getText(range: range(0, 4, 1, 1)),
        equals('e\nf'),
      );
    });

    test('invalid input at beginning of file', () {
      var document = createDocument('asdf');
      expect(document.offsetAt(position(-1, 0)), 0);
      expect(document.offsetAt(position(0, -1)), 0);

      var pos = document.positionAt(-1);
      expect(pos.line, equals(0));
      expect(pos.character, equals(0));
    });

    test('invalid input at end of file', () {
      var document = createDocument('asdf');
      expect(document.offsetAt(position(1, 1)), 4);

      var pos = document.positionAt(8);
      expect(pos.line, equals(0));
      expect(pos.character, equals(4));
    });

    test('invalid input at beginning of line', () {
      var document = createDocument('a\ns\nd\r\nf');
      expect(document.offsetAt(position(0, -1)), 0);
      expect(document.offsetAt(position(1, -1)), 2);
      expect(document.offsetAt(position(2, -1)), 4);
      expect(document.offsetAt(position(3, -1)), 7);
    });

    test('invalid input at end of line', () {
      var document = createDocument('a\ns\nd\r\nf');
      expect(document.offsetAt(position(0, 10)), 1);
      expect(document.offsetAt(position(1, 10)), 3);
      expect(document.offsetAt(position(2, 2)), 5);
      expect(document.offsetAt(position(2, 3)), 5);
      expect(document.offsetAt(position(2, 10)), 5);
      expect(document.offsetAt(position(3, 10)), 8);

      var pos = document.positionAt(6);
      expect(pos.line, equals(2));
      expect(pos.character, equals(1));
    });
  });

  group('full updates', () {
    test('one full update', () {
      var document = createDocument('asdfqwer');
      document.update([updateFull('hjklyuio')], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('hjklyuio'));
    });

    test('several full updates', () {
      var document = createDocument('asdfqwer');
      document.update([updateFull('hjklyuio'), updateFull('12345')], 2);
      expect(document.version, equals(2));
      expect(document.getText(), equals('12345'));
    });
  });

  group('incremental updates', () {
    void checkLineNumbers(TextDocument document) {
      // Assuming \n.
      var text = document.getText();
      var characters = text.split('');
      var expected = 0;
      for (var i = 0; i < text.length; i++) {
        expect(document.positionAt(i).line, expected);
        if (characters[i] == '\n') {
          expected += 1;
        }
      }
      expect(document.positionAt(text.length), equals(expected));
    }

    test('incrementally removing content', () {});
  });

  group('applyEdits', () {
    test('inserts', () {
      var input = createDocument('asdfasdfasdf');
      expect(
        input.applyEdits([insert('Hello', position(0, 0))]),
        equals('Helloasdfasdfasdf'),
      );
      expect(
        input.applyEdits([insert('Hello', position(0, 1))]),
        equals('aHellosdfasdfasdf'),
      );
      expect(
        input.applyEdits([
          insert('Hello', position(0, 1)),
          insert('World', position(0, 1)),
        ]),
        equals('aHelloWorldsdfasdfasdf'),
      );
      expect(
        input.applyEdits([
          insert('Mint', position(0, 2)),
          insert('Hello', position(0, 1)),
          insert('World', position(0, 1)),
          insert('Jams', position(0, 2)),
          insert('Casiopea', position(0, 2)),
        ]),
        equals('aHelloWorldsMintJamsCasiopeadfasdfasdf'),
      );
    });

    test('replace', () {
      var input = createDocument('0123456789');
      expect(
        input.applyEdits([replace('Hello', range(0, 3, 0, 5))]),
        equals('012Hello56789'),
      );
      expect(
        input.applyEdits([
          replace('Hello', range(0, 3, 0, 5)),
          replace('World', range(0, 5, 0, 7)),
        ]),
        equals('012HelloWorld789'),
      );
    });

    test('mix', () {
      var input = createDocument('0123456789');
      expect(
        input.applyEdits([
          insert('Jams', position(0, 6)),
          replace('Mint', range(0, 3, 0, 6)),
        ]),
        equals('012MintJams6789'),
      );
    });
  });
}
