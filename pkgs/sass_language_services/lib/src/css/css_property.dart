import 'css_value.dart';
import 'entry_status.dart';
import 'reference.dart';

class CssProperty {
  final String name;
  final String? description;
  final List<String>? browsers;
  final List<String>? restrictions;
  final EntryStatus? status;
  final String? syntax;
  final List<CssValue>? values;
  final List<Reference>? references;
  final int? relevance;
  final String? atRule;

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
