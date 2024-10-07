import 'editor_configuration.dart';
import 'language_configuration.dart';
import 'workspace_configuration.dart';

class LanguageServerConfiguration {
  LanguageConfiguration css;
  LanguageConfiguration scss;
  LanguageConfiguration sass;
  EditorConfiguration editor;
  WorkspaceConfiguration workspace;

  LanguageServerConfiguration(
      {required this.css,
      required this.scss,
      required this.sass,
      required this.editor,
      required this.workspace});
}
