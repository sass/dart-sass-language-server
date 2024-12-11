import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/utils/string_utils.dart';

import '../../css/css_data.dart';
import '../language_feature.dart';
import '../node_at_offset_visitor.dart';

class HoverFeature extends LanguageFeature {
  final _cssData = CssData();

  HoverFeature({required super.ls});

  bool _supportsMarkdown() =>
      ls.clientCapabilities.textDocument?.hover?.contentFormat
              ?.any((f) => f == lsp.MarkupKind.Markdown) ==
          true ||
      ls.clientCapabilities.general?.markdown != null;

  Future<lsp.Hover?> doHover(
      TextDocument document, lsp.Position position) async {
    var stylesheet = ls.parseStylesheet(document);
    var offset = document.offsetAt(position);
    var visitor = NodeAtOffsetVisitor(offset);
    var result = stylesheet.accept(visitor);

    // The visitor might have reached the end of the syntax tree,
    // in which case result is null. We still might have a candidate.
    var hoverNode = result ?? visitor.candidate;
    if (hoverNode == null) {
      return null;
    }

    lsp.Hover? hover;
    for (var i = 0; i < visitor.path.length; i++) {
      var node = visitor.path.elementAt(i);
      if (node is sass.SimpleSelector) {
        return _selectorHover(visitor.path, i);
      } else if (node is sass.Declaration) {
        return _declarationHover(node);
      }
    }

    return hover;
  }

  lsp.Hover _selectorHover(List<sass.AstNode> path, int index) {
    var (selector, specificity) = _getSelectorHoverValue(path, index);

    if (_supportsMarkdown()) {
      var contents = _asMarkdown('''```scss
$selector
```

[Specificity](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity): ${readableSpecificity(specificity)}
''');
      return lsp.Hover(contents: contents);
    } else {
      var contents = _asPlaintext('''
$selector

Specificity: ${readableSpecificity(specificity)}
''');
      return lsp.Hover(contents: contents);
    }
  }

  /// Go back up the path and calculate a full selector string and specificity.
  (String, int) _getSelectorHoverValue(List<sass.AstNode> path, int index) {
    var selector = "";
    var specificity = 0;
    var pastImmediateStyleRule = false;
    var lastWasParentSelector = false;

    for (var i = index; i >= 0; i--) {
      var node = path.elementAt(i);
      if (node is sass.ComplexSelector) {
        var sel = node.span.text;
        if (sel.startsWith('&')) {
          lastWasParentSelector = true;
          selector = "${sel.substring(1)} $selector";
          specificity += node.specificity;
        } else {
          if (lastWasParentSelector) {
            selector = "$sel$selector";
          } else {
            selector = "$sel $selector";
          }
          specificity += node.specificity;
        }
      } else if (node is sass.StyleRule) {
        // Don't add the direct parent StyleRule,
        // otherwise we'll end up with the same selector twice.
        if (!pastImmediateStyleRule) {
          pastImmediateStyleRule = true;
          continue;
        }

        try {
          if (node.selector.isPlain) {
            var selectorList = sass.SelectorList.parse(node.selector.asPlain!);

            // Just pick the first one in case of a list.
            var ruleSelector = selectorList.components.first;
            var selectorString = ruleSelector.toString();
            if (selectorString.startsWith('&')) {
              lastWasParentSelector = true;
              selector = "${selectorString.substring(1)} $selector";
              specificity += ruleSelector.specificity;
              continue;
            } else {
              if (lastWasParentSelector) {
                selector = "$selectorString$selector";
                // subtract one class worth that would otherwise be duplicated
                specificity -= 1000;
              } else {
                selector = "$selectorString $selector";
              }
              specificity += ruleSelector.specificity;
            }
          }
        } on sass.SassFormatException catch (_) {
          // Do nothing.
        }

        lastWasParentSelector = false;
      }
    }

    return (selector.trim(), specificity);
  }

  lsp.Either2<lsp.MarkupContent, String> _asMarkdown(String content) {
    return lsp.Either2.t1(
      lsp.MarkupContent(
        kind: lsp.MarkupKind.Markdown,
        value: content,
      ),
    );
  }

  lsp.Either2<lsp.MarkupContent, String> _asPlaintext(String content) {
    return lsp.Either2.t1(
      lsp.MarkupContent(
        kind: lsp.MarkupKind.PlainText,
        value: content,
      ),
    );
  }

  Future<lsp.Hover?> _declarationHover(sass.Declaration node) async {
    var data = _cssData.getProperty(node.name.toString());
    if (data == null) return null;

    var description = data.description;
    var syntax = data.syntax;

    final re = RegExp(r'([A-Z]+)(\d+)?');
    const browserNames = {
      "E": "Edge",
      "FF": "Firefox",
      "S": "Safari",
      "C": "Chrome",
      "IE": "IE",
      "O": "Opera",
    };

    if (_supportsMarkdown()) {
      var browsers = data.browsers?.map<String>((b) {
        var matches = re.firstMatch(b);
        if (matches != null) {
          var browser = matches.group(1);
          var version = matches.group(2);
          return "| ${browserNames[browser]} | $version |";
        }
        return b;
      }).join('\n');

      var references = data.references
          ?.map<String>((r) => '[${r.name}](${r.uri.toString()})')
          .join('\n');
      var contents = _asMarkdown('''
$description

Syntax: $syntax

$references

| Browser | Since version |
| -- | -- |
$browsers
'''
          .trim());
      return lsp.Hover(contents: contents);
    } else {
      var browsers = data.browsers?.map<String>((b) {
        var matches = re.firstMatch(b);
        if (matches != null) {
          var browser = matches.group(1);
          var version = matches.group(2);
          return "${browserNames[browser]} $version";
        }
        return b;
      }).join(', ');

      var contents = _asPlaintext('''
$description

Syntax: $syntax

$browsers
''');
      return lsp.Hover(contents: contents);
    }
  }
}
