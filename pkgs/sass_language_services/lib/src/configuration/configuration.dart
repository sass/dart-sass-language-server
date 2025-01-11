import 'editor_configuration.dart';
import 'language_configuration.dart';
import 'workspace_configuration.dart';

/// User configuration for the different language server features.
class LanguageServerConfiguration {
  late LanguageConfiguration css;
  late LanguageConfiguration scss;
  late LanguageConfiguration sass;
  late EditorConfiguration editor;
  late WorkspaceConfiguration workspace;

  LanguageServerConfiguration.create(dynamic config) {
    var extensionConfig = config?['sass'];
    var editorConfig = config?['editor'];

    css = LanguageConfiguration.from(extensionConfig?['css']);
    scss = LanguageConfiguration.from(extensionConfig?['scss']);
    sass = LanguageConfiguration.from(extensionConfig?['sass']);
    workspace = WorkspaceConfiguration.from(extensionConfig?['workspace']);
    editor = EditorConfiguration.from(editorConfig);
  }

  void update(dynamic config) {
    var extensionConfig = config?['sass'];
    if (extensionConfig != null) {
      css = LanguageConfiguration.from(extensionConfig?['css']);
      scss = LanguageConfiguration.from(extensionConfig?['scss']);
      sass = LanguageConfiguration.from(extensionConfig?['sass']);
      workspace = WorkspaceConfiguration.from(extensionConfig?['workspace']);
    }
    var editorConfig = config?['editor'];
    if (editorConfig != null) {
      editor = EditorConfiguration.from(editorConfig);
    }
  }
}
