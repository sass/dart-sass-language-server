import 'entry_status.dart';
import 'reference.dart';

class CssAtDirective {
  String name;
  String? description;
  List<String>? browsers;
  EntryStatus? status;
  List<Reference>? references;

  CssAtDirective(this.name,
      {this.description, this.browsers, this.status, this.references});
}