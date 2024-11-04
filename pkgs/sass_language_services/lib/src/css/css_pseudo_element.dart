import 'entry_status.dart';
import 'reference.dart';

class CssPseudoElement {
  String name;
  String? description;
  List<String>? browsers;
  EntryStatus? status;
  List<Reference>? references;

  CssPseudoElement(this.name,
      {this.description, this.browsers, this.status, this.references});
}
