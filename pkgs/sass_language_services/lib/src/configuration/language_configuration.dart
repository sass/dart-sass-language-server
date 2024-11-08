class FeatureConfiguration {
  late final bool enabled;

  FeatureConfiguration({required this.enabled});
}

class DocumentSymbolsConfiguration extends FeatureConfiguration {
  DocumentSymbolsConfiguration({required super.enabled});
}

class DocumentLinksConfiguration extends FeatureConfiguration {
  DocumentLinksConfiguration({required super.enabled});
}

class LanguageConfiguration {
  late final DocumentSymbolsConfiguration documentSymbols;
  late final DocumentLinksConfiguration documentLinks;

  LanguageConfiguration.from(dynamic config) {
    documentSymbols = DocumentSymbolsConfiguration(
        enabled: config?['documentSymbols']?['enabled'] as bool? ?? true);
    documentLinks = DocumentLinksConfiguration(
        enabled: config?['documentLinks']?['enabled'] as bool? ?? true);
  }
}
