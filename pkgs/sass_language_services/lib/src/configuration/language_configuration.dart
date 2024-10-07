class LanguageConfiguration {
  /// Exclude paths from the initial workspace scan. Defaults include `.git` and `node_modules`.
  late final List<String> exclude;
  late final Map<String, dynamic> importAliases;

  /// Pass in [load paths](https://sass-lang.com/documentation/cli/dart-sass/#load-path) that will be used in addition to `node_modules`.
  late final List<String> loadPaths;
  late final Uri? workspaceRoot;

  LanguageConfiguration.from(Map<dynamic, dynamic> config) {
    exclude = config["exclude"] as List<String>? ?? [];
    importAliases = config["importAliases"] as Map<String, dynamic>? ?? {};
    loadPaths = config["loadPaths"] as List<String>? ?? [];
    workspaceRoot = config["workspaceRoot"] as Uri?;
  }
}
