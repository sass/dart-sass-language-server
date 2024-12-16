class FeatureConfiguration {
  final bool enabled;

  FeatureConfiguration({required this.enabled});
}

class HoverConfiguration extends FeatureConfiguration {
  final bool documentation;
  final bool references;

  HoverConfiguration({
    required super.enabled,
    required this.documentation,
    required this.references,
  });
}

class LanguageConfiguration {
  late final FeatureConfiguration definition;
  late final FeatureConfiguration documentSymbols;
  late final FeatureConfiguration documentLinks;
  late final FeatureConfiguration foldingRanges;
  late final FeatureConfiguration highlights;
  late final HoverConfiguration hover;
  late final FeatureConfiguration references;
  late final FeatureConfiguration rename;
  late final FeatureConfiguration selectionRanges;
  late final FeatureConfiguration workspaceSymbols;

  LanguageConfiguration.from(dynamic config) {
    definition = FeatureConfiguration(
        enabled: config?['definition']?['enabled'] as bool? ?? true);
    documentSymbols = FeatureConfiguration(
        enabled: config?['documentSymbols']?['enabled'] as bool? ?? true);
    documentLinks = FeatureConfiguration(
        enabled: config?['documentLinks']?['enabled'] as bool? ?? true);
    foldingRanges = FeatureConfiguration(
        enabled: config?['foldingRanges']?['enabled'] as bool? ?? true);
    highlights = FeatureConfiguration(
        enabled: config?['highlights']?['enabled'] as bool? ?? true);

    hover = HoverConfiguration(
      enabled: config?['hover']?['enabled'] as bool? ?? true,
      documentation: config?['hover']?['documentation'] as bool? ?? true,
      references: config?['hover']?['references'] as bool? ?? true,
    );

    references = FeatureConfiguration(
        enabled: config?['references']?['enabled'] as bool? ?? true);
    rename = FeatureConfiguration(
        enabled: config?['rename']?['enabled'] as bool? ?? true);
    selectionRanges = FeatureConfiguration(
        enabled: config?['selectionRanges']?['enabled'] as bool? ?? true);
    workspaceSymbols = FeatureConfiguration(
        enabled: config?['workspaceSymbols']?['enabled'] as bool? ?? true);
  }
}
