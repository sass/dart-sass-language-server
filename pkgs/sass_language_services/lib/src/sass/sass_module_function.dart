class SassModuleFunction {
  final String name;
  final String description;
  final String signature;
  final String parameterSnippet;
  final String returns;

  final Uri? reference;
  final String? deprecationMessage;

  SassModuleFunction(this.name, this.description, this.signature,
      this.parameterSnippet, this.returns,
      {this.reference, this.deprecationMessage});

  bool get isDeprecated => deprecationMessage != null;
}
