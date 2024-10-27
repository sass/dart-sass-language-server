class FeatureConfiguration {
  late final bool enabled;

  FeatureConfiguration({required this.enabled});
}

class DefinitionConfiguration extends FeatureConfiguration {
  DefinitionConfiguration({required super.enabled});
}

class LinksConfiguration extends FeatureConfiguration {
  LinksConfiguration({required super.enabled});
}

class LanguageConfiguration {
  late final DefinitionConfiguration definition;
  late final LinksConfiguration links;

  LanguageConfiguration.from(dynamic config) {
    definition = DefinitionConfiguration(
        enabled: config?['definition']?['enabled'] as bool? ?? true);
    links = LinksConfiguration(
        enabled: config?['links']?['enabled'] as bool? ?? true);
  }
}
