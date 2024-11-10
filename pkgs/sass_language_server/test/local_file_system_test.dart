import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:test/test.dart';

void main() {
  group('Glob', () {
    test('default exclude patterns match paths as expected', () {
      var config = WorkspaceConfiguration.from(null);
      var excludeGlobs = <Glob>[];
      for (var pattern in config.exclude) {
        excludeGlobs.add(Glob(pattern,
            caseSensitive: false, context: p.Context(style: p.Style.url)));
      }

      var nodeModulesPath =
          '/home/user/workspace/project/node_modules/dependency/styles/index.scss';

      var nodeModulesGlob = excludeGlobs.last;

      var matches = nodeModulesGlob.matches(nodeModulesPath);
      expect(matches, isTrue);
    });

    test('user provided exclude patterns match paths as expected', () {
      var config = WorkspaceConfiguration.from({
        'exclude': ['node_modules/**']
      });

      var excludeGlobs = <Glob>[];
      for (var pattern in config.exclude) {
        excludeGlobs.add(Glob(pattern,
            caseSensitive: false, context: p.Context(style: p.Style.url)));
      }

      var nodeModulesPath =
          '/home/user/workspace/project/node_modules/dependency/styles/index.scss';

      var nodeModulesGlob = excludeGlobs.first;

      var matches = nodeModulesGlob.matches(nodeModulesPath);
      expect(matches, isTrue);
    });
  });
}
