import 'entry_status.dart';
import 'reference.dart';

class CssAtDirective {
  final String name;
  final String? description;
  final List<String>? browsers;
  final EntryStatus? status;
  final List<Reference>? references;

  CssAtDirective(this.name,
      {this.description, this.browsers, this.status, this.references});
}
