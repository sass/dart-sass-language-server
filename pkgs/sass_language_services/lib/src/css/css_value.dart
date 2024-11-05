import 'entry_status.dart';
import 'reference.dart';

class CssValue {
  String name;
  String? description;
  List<String>? browsers;
  EntryStatus? status;
  List<Reference>? references;

  CssValue(this.name,
      {this.description, this.browsers, this.status, this.references});
}
