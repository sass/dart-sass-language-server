class WorkspaceConfiguration {
  /// Exclude paths from the initial workspace scan. Defaults include `.git` and `node_modules`.
  final List<String> exclude = ['/**/.git/**', '/**/node_modules/**'];
  final Map<String, String> importAliases = {};

  /// Pass in [load paths](https://sass-lang.com/documentation/cli/dart-sass/#load-path) that will be used in addition to `node_modules`.
  final List<String> loadPaths = [];
  late final String logLevel;

  Uri? workspaceRoot;

  WorkspaceConfiguration.from(dynamic config) {
    var excludeConfig = config?['exclude'];
    if (excludeConfig is List) {
      exclude.removeRange(0, exclude.length);
      for (var entry in excludeConfig) {
        if (entry is String) {
          if (entry.startsWith('/')) {
            exclude.add(entry);
          } else {
            // Paths we match against using Glob are absolute.
            exclude.add('/**/$entry');
          }
        }
      }
    }

    var loadPathsConfig = config?['loadPaths'];
    if (loadPathsConfig is List) {
      loadPaths.removeRange(0, loadPaths.length);
      for (var entry in loadPathsConfig) {
        if (entry is String) {
          loadPaths.add(entry);
        }
      }
    }

    var importAliasesConfig = config?['importAliases'];
    if (importAliasesConfig is Map) {
      for (var key in importAliases.keys) {
        importAliases.remove(key);
      }

      for (var entry in importAliasesConfig.entries) {
        if (entry.key is String && entry.value is String) {
          importAliases[entry.key as String] = entry.value as String;
        }
      }
    }

    logLevel = config?['logLevel'] as String? ?? 'info';
  }
}
