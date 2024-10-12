class WorkspaceConfiguration {
  /// Exclude paths from the initial workspace scan. Defaults include `.git` and `node_modules`.
  late final List<String> exclude;
  late final Map<String, String> importAliases;

  /// Pass in [load paths](https://sass-lang.com/documentation/cli/dart-sass/#load-path) that will be used in addition to `node_modules`.
  late final List<String> loadPaths;
  late final String logLevel;
  late final Uri? workspaceRoot;

  WorkspaceConfiguration.from(dynamic config) {
    exclude = config?["exclude"] as List<String>? ??
        ["**/.git/**", "**/node_modules/**"];
    importAliases = config?["importAliases"] as Map<String, String>? ?? {};
    loadPaths = config?["loadPaths"] as List<String>? ?? [];
    logLevel = config?["logLevel"] as String? ?? 'info';
    workspaceRoot = config?["workspaceRoot"] as Uri?;
  }
}
