import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

import '../../memory_file_system.dart';
import '../../test_client_capabilities.dart';

final fs = MemoryFileSystem();
final ls = LanguageServices(fs: fs, clientCapabilities: getCapabilities());

void main() {
  group('Document links', () {
    test('should resolve valid links', () async {
      fs.createDocument('\$var: 1px;', uri: 'variables.scss');
      fs.createDocument('\$tr: 2px;', uri: 'corners.scss');
      fs.createDocument('\$b: #000;', uri: 'colors.scss');

      var document = fs.createDocument('''
@use "corners" as *;
@use "variables" as vars;
@forward "colors" as color-* hide \$foo, barfunc;
@forward "./does-not-exist" as foo-* show \$public;
''');

      var links = await ls.findDocumentLinks(document);
      expect(links.length, 4);

      var use = links.where((link) => link.type == LinkType.use);
      var forward = links.where((link) => link.type == LinkType.forward);

      expect(use.length, 2);
      expect(forward.length, 2);

      expect(use.last.namespace, 'vars');
      expect(use.first.namespace, null,
          reason: 'Expected wildcard @use not to have a namespace');

      expect(forward.last.shownVariables, {'public'});
      expect(forward.first.hiddenVariables, {'foo'});
      expect(forward.first.hiddenMixinsAndFunctions, {'barfunc'});
      expect(forward.first.prefix, 'color-');
      expect(forward.last.prefix, 'foo-');

      expect(use.first.target != null, true);
      expect(use.last.target != null, true);
      expect(forward.first.target != null, true);

      expect(forward.last.target != null, true,
          reason:
              'Expected to have a target even though the file does not exist in our file system.');
    });

    test('should resolve various relative links', () async {
      fs.createDocument('\$var: 1px;', uri: 'upper.scss');
      fs.createDocument('\$tr: 2px;', uri: 'middle/middle.scss');
      fs.createDocument('\$b: #000;', uri: 'middle/lower/lower.scss');

      var document = fs.createDocument('''
@use "../upper";
@use "./middle";
@use "./lower/lower";
''', uri: 'middle/main.scss');

      var links = await ls.findDocumentLinks(document);

      equals(links.length, 3);
    });

    test('should not break on circular references', () async {
      fs.createDocument('''
@use "./pong"
\$var: ping
''', uri: 'ping.sass');

      var document = fs.createDocument('''
@use "./pong"
\$var: ping
''', uri: 'ping.sass');

      var links = await ls.findDocumentLinks(document);

      expect(links.length, 1);
    });

    // TODO: tests for partials
    // TODO: test for CSS imports (@import 'foo.css')
    // TODO: test for Sass imports (with and without string quotes)
  });
}
