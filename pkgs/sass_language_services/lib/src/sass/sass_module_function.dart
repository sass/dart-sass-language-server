class SassModuleFunction {
  final String name;
  final String description;
  final String signature;
  final String parameterSnippet;
  final String returns;

  final Uri? reference;
  final String? deprecationMessage;

  SassModuleFunction(this.name,
      {required this.description,
      required this.signature,
      required this.parameterSnippet,
      required this.returns,
      this.reference,
      this.deprecationMessage});

  bool get isDeprecated => deprecationMessage != null;
}