import 'editor_configuration.dart';
import 'language_configuration.dart';
import 'workspace_configuration.dart';

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
    var extension = config?['sass'];
    if (extension != null) {
      css = LanguageConfiguration.from(extension?['css']);
      scss = LanguageConfiguration.from(extension?['scss']);
      sass = LanguageConfiguration.from(extension?['sass']);
      workspace = WorkspaceConfiguration.from(extension?['workspace']);
    }
    var editorConfig = config?['editor'];
    if (editorConfig != null) {
      editor = EditorConfiguration.from(editorConfig);
    }
  }
}
