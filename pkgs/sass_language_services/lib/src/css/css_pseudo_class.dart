import 'entry_status.dart';
import 'reference.dart';

class CssPseudoClass {
  final String name;
  final String? description;
  final List<String>? browsers;
  final EntryStatus? status;
  final List<Reference>? references;

  CssPseudoClass(this.name,
      {this.description, this.browsers, this.status, this.references});
}
