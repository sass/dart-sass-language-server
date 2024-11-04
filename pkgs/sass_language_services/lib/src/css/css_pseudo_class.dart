import 'entry_status.dart';
import 'reference.dart';

class CssPseudoClass {
  String name;
  String? description;
  List<String>? browsers;
  EntryStatus? status;
  List<Reference>? references;

  CssPseudoClass(this.name,
      {this.description, this.browsers, this.status, this.references});
}
