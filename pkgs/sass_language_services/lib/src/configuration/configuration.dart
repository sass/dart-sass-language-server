import 'editor_configuration.dart';
import 'language_configuration.dart';
import 'workspace_configuration.dart';

class LanguageServerConfiguration {
  late final LanguageConfiguration css;
  late final LanguageConfiguration scss;
  late final LanguageConfiguration sass;
  late final EditorConfiguration editor;
  late final WorkspaceConfiguration workspace;

  LanguageServerConfiguration.from(dynamic config) {
    css = LanguageConfiguration.from(config?['css']);
    scss = LanguageConfiguration.from(config?['scss']);
    sass = LanguageConfiguration.from(config?['sass']);
    editor = EditorConfiguration.from(config?['editor']);
    workspace = WorkspaceConfiguration.from(config?['workspace']);
  }
}
