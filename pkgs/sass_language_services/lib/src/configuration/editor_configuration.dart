class EditorConfiguration {
  /// Control the max number of color decorators that can be rendered in an editor at once. The default value is 500.
  late final int colorDecoratorsLimit;

  /// Specify how many spaces to insert per indent level if [insertSpaces] is true. The default value is 2.
  late final int indentSize;

  /// Insert spaces rather than tabs. Default value is false, meaning tabs are used.
  late final bool insertSpaces;

  EditorConfiguration.from(dynamic config) {
    colorDecoratorsLimit = config?["colorDecoratorsLimit"] as int? ?? 500;
    indentSize = config?["indentSize"] as int? ?? 2;
    insertSpaces = config?["insertSpaces"] as bool? ?? false;
  }
}
