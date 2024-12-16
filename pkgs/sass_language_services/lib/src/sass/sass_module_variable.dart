class SassModuleVariable {
  final String name;
  final String description;

  final String? deprecationMessage;

  SassModuleVariable(this.name,
      {required this.description, this.deprecationMessage});

  bool get isDeprecated => deprecationMessage != null;
}
