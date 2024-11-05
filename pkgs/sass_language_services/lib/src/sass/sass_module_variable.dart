class SassModuleVariable {
  final String name;
  final String description;

  final Uri? reference;
  final String? deprecationMessage;

  SassModuleVariable(this.name,
      {required this.description, this.reference, this.deprecationMessage});

  bool get isDeprecated => deprecationMessage != null;
}
