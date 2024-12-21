import 'package:lsp_server/lsp_server.dart' as lsp;

import '../utils/sass_lsp_utils.dart';
import 'css_value.dart';
import 'entry_status.dart';
import 'reference.dart';

final re = RegExp(r'([A-Z]+)(\d+)?');
const browserNames = {
  "E": "Edge",
  "FF": "Firefox",
  "S": "Safari",
  "C": "Chrome",
  "IE": "IE",
  "O": "Opera",
};

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

  CssProperty(
    this.name, {
    this.description,
    this.browsers,
    this.restrictions,
    this.status,
    this.syntax,
    this.values,
    this.references,
    this.relevance,
    this.atRule,
  });

  lsp.Either2<lsp.MarkupContent, String> getPlaintextDescription() {
    var browsersString = browsers?.map<String>((b) {
      var matches = re.firstMatch(b);
      if (matches != null) {
        var browser = matches.group(1);
        var version = matches.group(2);
        return "${browserNames[browser]} $version";
      }
      return b;
    }).join(', ');

    var contents = asPlaintext('''
$description

Syntax: $syntax

$browsersString
''');
    return contents;
  }

  lsp.Either2<lsp.MarkupContent, String> getMarkdownDescription() {
    var browsersString = browsers?.map<String>((b) {
      var matches = re.firstMatch(b);
      if (matches != null) {
        var browser = matches.group(1);
        var version = matches.group(2);
        return "${browserNames[browser]} $version";
      }
      return b;
    }).join(', ');

    var referencesString = references
        ?.map<String>((r) => '[${r.name}](${r.uri.toString()})')
        .join('\n');

    var contents = asMarkdown('''
$description

Syntax: $syntax

$referencesString

$browsersString
'''
        .trim());
    return contents;
  }
}
