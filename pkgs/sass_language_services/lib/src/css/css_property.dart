import 'css_value.dart';
import 'entry_status.dart';
import 'reference.dart';

class CssProperty {
  String name;
  String? description;
  List<String>? browsers;
  List<String>? restrictions;
  EntryStatus? status;
  String? syntax;
  List<CssValue>? values;
  List<Reference>? references;
  int? relevance;
  String? atRule;

  CssProperty(this.name,
      {this.description,
      this.browsers,
      this.restrictions,
      this.status,
      this.syntax,
      this.values,
      this.references,
      this.relevance,
      this.atRule});
}
