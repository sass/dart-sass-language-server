import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('Document links', () {
    setUp(() {
      ls.cache.clear();
    });

    test('should resolve valid links', () async {
      fs.createDocument(r'$var: 1px;', uri: 'variables.scss');
      fs.createDocument(r'$tr: 2px;', uri: 'corners.scss');
      fs.createDocument(r'$b: #000;', uri: 'colors.scss');

      var document = fs.createDocument(r'''
@use "corners" as *;
@use "variables" as vars;
@forward "colors" as color-* hide $foo, barfunc;
@forward "./does-not-exist" as foo-* show $public;
''');

      var links = await ls.findDocumentLinks(document);
      expect(links.length, equals(4));

      var use = links.where((link) => link.type == LinkType.use);
      var forward = links.where((link) => link.type == LinkType.forward);

      expect(use.length, equals(2));
      expect(forward.length, equals(2));

      expect(use.last.namespace, equals('vars'));
      expect(use.first.namespace, isNull,
          reason: 'Expected wildcard @use not to have a namespace');

      expect(forward.last.shownVariables, equals({'public'}));
      expect(forward.first.hiddenVariables, equals({'foo'}));
      expect(forward.first.hiddenMixinsAndFunctions, equals({'barfunc'}));
      expect(forward.first.prefix, equals('color-'));
      expect(forward.last.prefix, equals('foo-'));

      expect(use.first.target!.path, endsWith('corners.scss'));
      expect(use.last.target!.path, endsWith('variables.scss'));
      expect(forward.first.target!.path, endsWith('colors.scss'));

      expect(forward.last.target!.path, endsWith('does-not-exist'),
          reason:
              'Expected to have a target even though the file does not exist in our file system.');
    });

    test('should resolve various relative links', () async {
      fs.createDocument(r'$var: 1px;', uri: 'upper.scss');
      fs.createDocument(r'$tr: 2px;', uri: 'middle/middle.scss');
      fs.createDocument(r'$b: #000;', uri: 'middle/lower/lower.scss');

      var document = fs.createDocument('''
@use "../upper";
@use "./middle";
@use "./lower/lower";
''', uri: 'middle/main.scss');

      var links = await ls.findDocumentLinks(document);

      expect(links.length, equals(3));
    });

    test('should not break on circular references', () async {
      fs.createDocument(r'''
@use "./pong"
$var: ping
''', uri: 'ping.sass');

      var document = fs.createDocument(r'''
@use "./pong"
$var: ping
''', uri: 'ping.sass');

      var links = await ls.findDocumentLinks(document);

      expect(links.length, equals(1));
    });

    test('handles various forms of partials', () async {
      fs.createDocument(r'''
$foo: blue;
''', uri: '_foo.scss');

      fs.createDocument(r'''
$bar: red
''', uri: 'bar/_index.sass');

      var document = fs.createDocument('''
@use "foo";
@use "bar";
''');

      var links = await ls.findDocumentLinks(document);

      expect(links.length, equals(2));

      expect(links.first.target!.path, endsWith('_foo.scss'));
      expect(links.last.target!.path, endsWith('bar/_index.sass'));
    });

    test('handles CSS imports', () async {
      var links = await ls.findDocumentLinks(fs.createDocument('''
@import "string.css";
'''));
      expect(links.first.target!.path, endsWith('string.css'));
    });

    test('handles remote CSS imports', () async {
      var links = await ls.findDocumentLinks(fs.createDocument('''
@import 'http://foo.com/foo.css';
'''));
      expect(links.first.target!.toString(), equals('http://foo.com/foo.css'));
    });

    test('handles CSS url function imports', () async {
      var links = await ls.findDocumentLinks(fs.createDocument('''
@import url("func.css") print;
'''));
      expect(links.first.target!.path, endsWith('func.css'));
    });

    test('handles Sass imports without string quotes', () async {
      fs.createDocument(r'''
$foo: blue;
''', uri: '_foo.scss');

      var links = await ls.findDocumentLinks(fs.createDocument('''
@import foo
''', uri: 'index.sass'));

      expect(links.first.target!.path, endsWith('_foo.scss'));
    });
  });
}
