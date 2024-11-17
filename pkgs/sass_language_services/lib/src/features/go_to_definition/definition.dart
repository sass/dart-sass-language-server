import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';

class Definition {
  final String name;
  final ReferenceKind kind;
  lsp.Location? location;

  Definition(this.name, this.kind, this.location);
}
