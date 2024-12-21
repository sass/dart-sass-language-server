import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/utils/sass_lsp_utils.dart';
import 'package:sass_language_services/src/utils/string_utils.dart';

import '../go_to_definition/go_to_definition_feature.dart';
import '../node_at_offset_visitor.dart';

class HoverFeature extends GoToDefinitionFeature {
  HoverFeature({required super.ls});

  Future<lsp.Hover?> doHover(
      TextDocument document, lsp.Position position) async {
    var stylesheet = ls.parseStylesheet(document);
    var offset = document.offsetAt(position);
    var path = getNodePathAtOffset(stylesheet, offset);

    lsp.Hover? hover;

    for (var i = 0; i < path.length; i++) {
      var node = path.elementAt(i);
      if (node is sass.SimpleSelector) {
        return _selectorHover(path, i);
      } else if (node is sass.Declaration) {
        hover = _declarationHover(node);
      } else if (node is sass.VariableExpression) {
        hover = await _variableHover(node, document, position);
      } else if (node is sass.FunctionExpression) {
        hover = await _functionHover(node, document, position);
      } else if (node is sass.IncludeRule) {
        hover = await _mixinHover(node, document, position);
      }
    }

    return hover;
  }

  lsp.Hover _selectorHover(List<sass.AstNode> path, int index) {
    var (selector, specificity) = _getSelectorHoverValue(path, index);

    if (supportsMarkdown()) {
      var contents = asMarkdown('''```scss
$selector
```

[Specificity](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity): ${readableSpecificity(specificity)}
''');
      return lsp.Hover(contents: contents);
    } else {
      var contents = asPlaintext('''
$selector

Specificity: ${readableSpecificity(specificity)}
''');
      return lsp.Hover(contents: contents);
    }
  }

  /// Go back up the path and calculate a full selector string and specificity.
  (String, int) _getSelectorHoverValue(List<sass.AstNode> path, int index) {
    var pre = "";
    var selector = "";
    var specificity = 0;
    var pastImmediateStyleRule = false;
    var lastWasParentSelector = false;

    for (var i = index; i >= 0; i--) {
      var node = path.elementAt(i);
      if (node is sass.ComplexSelector) {
        var sel = node.span.text;
        var parentSelectorIndex = sel.indexOf('&');
        if (parentSelectorIndex != -1) {
          lastWasParentSelector = true;

          pre = sel.substring(0, parentSelectorIndex);
          var post = sel.substring(parentSelectorIndex + 1);
          selector = "$post $selector";
          specificity += node.specificity;
        } else {
          if (lastWasParentSelector) {
            lastWasParentSelector = false;
            selector = "$pre$sel$selector";
            pre = "";
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
            var sel = ruleSelector.toString();

            if (lastWasParentSelector) {
              lastWasParentSelector = false;

              var parentSelectorIndex = sel.indexOf('&');
              if (parentSelectorIndex != -1) {
                lastWasParentSelector = true;
                pre = "$pre ${sel.substring(0, parentSelectorIndex)}".trim();
                var post = sel.substring(parentSelectorIndex + 1);
                selector = "$post$selector";
              } else {
                selector = "$pre $sel$selector".trim();
                pre = "";
              }
              // subtract one class worth that would otherwise be duplicated
              specificity -= 1000;
            } else {
              var parentSelectorIndex = sel.indexOf('&');
              if (parentSelectorIndex != -1) {
                lastWasParentSelector = true;
                pre = sel.substring(0, parentSelectorIndex);
                var post = sel.substring(parentSelectorIndex + 1);
                selector = "$post $selector";
              } else {
                selector = "$pre $sel $selector".trim();
              }
            }
            specificity += ruleSelector.specificity;
          }
        } on sass.SassFormatException catch (_) {
          // Do nothing.
        }
      }
    }

    return (selector.trim(), specificity);
  }

  lsp.Hover? _declarationHover(sass.Declaration node) {
    var data = cssData.getProperty(node.name.toString());
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

    if (supportsMarkdown()) {
      var browsers = data.browsers?.map<String>((b) {
        var matches = re.firstMatch(b);
        if (matches != null) {
          var browser = matches.group(1);
          var version = matches.group(2);
          return "${browserNames[browser]} $version";
        }
        return b;
      }).join(', ');

      var references = data.references
          ?.map<String>((r) => '[${r.name}](${r.uri.toString()})')
          .join('\n');
      var contents = asMarkdown('''
$description

Syntax: $syntax

$references

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

      var contents = asPlaintext('''
$description

Syntax: $syntax

$browsers
''');
      return lsp.Hover(contents: contents);
    }
  }

  Future<lsp.Hover?> _variableHover(sass.VariableExpression node,
      TextDocument document, lsp.Position position) async {
    var name = node.nameSpan.text;
    var range = toRange(node.nameSpan);

    var definition = await internalGoToDefinition(document, range.start);
    if (definition == null || definition.location == null) {
      // If we don't have a location we are likely dealing with a built-in.
      for (var module in sassData.modules) {
        for (var variable in module.variables) {
          if ('\$${variable.name}' == name) {
            if (supportsMarkdown()) {
              var contents = asMarkdown('''
${variable.description}

[Sass reference](${module.reference}#${variable.name})
''');
              return lsp.Hover(contents: contents, range: range);
            } else {
              var contents = asPlaintext(variable.description);
              return lsp.Hover(contents: contents, range: range);
            }
          }
        }
      }
      return null;
    }

    var definitionDocument = ls.cache.getDocument(definition.location!.uri);
    if (definitionDocument == null) {
      return null;
    }

    var definitionStylesheet = ls.parseStylesheet(definitionDocument);
    var path = getNodePathAtOffset(
      definitionStylesheet,
      definitionDocument.offsetAt(definition.location!.range.start),
    );

    String? docComment;
    String? rawValue;
    for (var i = 0; i < path.length; i++) {
      var node = path.elementAt(i);
      if (node is sass.VariableDeclaration) {
        docComment = node.comment?.docComment;
        rawValue = node.expression.toString();
        break;
      }
    }

    String? resolvedValue;
    if (rawValue != null && rawValue.contains(r'$')) {
      resolvedValue = await findVariableValue(
        definitionDocument,
        definition.location!.range.start,
      );
    }

    if (supportsMarkdown()) {
      var contents = asMarkdown('''
```${document.languageId}
$name: ${resolvedValue ?? rawValue}${document.languageId != 'sass' ? ';' : ''}
```${docComment != null ? '\n____\n${docComment.replaceAll('\n', '\n\n')}\n\n' : ''}
''');
      return lsp.Hover(contents: contents, range: range);
    } else {
      var contents = asPlaintext('''
$name: ${resolvedValue ?? rawValue}${document.languageId != 'sass' ? ';' : ''}${docComment != null ? '\n\n$docComment' : ''}
''');
      return lsp.Hover(contents: contents, range: range);
    }
  }

  Future<lsp.Hover?> _functionHover(sass.FunctionExpression node,
      TextDocument document, lsp.Position position) async {
    var name = node.nameSpan.text;
    var range = toRange(node.nameSpan);

    var definition = await internalGoToDefinition(document, range.start);
    if (definition == null || definition.location == null) {
      // If we don't have a location we may be dealing with a built-in.
      for (var module in sassData.modules) {
        for (var function in module.functions) {
          if (function.name == name) {
            if (supportsMarkdown()) {
              var contents = asMarkdown('''
${function.description}

[Sass reference](${module.reference}#${function.name})
''');
              return lsp.Hover(contents: contents, range: range);
            } else {
              var contents = asPlaintext(function.description);
              return lsp.Hover(contents: contents, range: range);
            }
          }
        }
      }
      return null;
    }

    var definitionDocument = ls.cache.getDocument(definition.location!.uri);
    if (definitionDocument == null) {
      return null;
    }

    var definitionStylesheet = ls.parseStylesheet(definitionDocument);
    var path = getNodePathAtOffset(
      definitionStylesheet,
      definitionDocument.offsetAt(definition.location!.range.start),
    );

    String? docComment;
    String arguments = '()';
    for (var i = 0; i < path.length; i++) {
      var node = path.elementAt(i);
      if (node is sass.FunctionRule) {
        docComment = node.comment?.docComment;
        arguments = '(${node.arguments.toString()})';
        break;
      }
    }

    if (supportsMarkdown()) {
      var contents = asMarkdown('''
```${document.languageId}
@function $name$arguments
```${docComment != null ? '\n____\n${docComment.replaceAll('\n', '\n\n')}\n\n' : ''}
''');
      return lsp.Hover(contents: contents, range: range);
    } else {
      var contents = asPlaintext('''
@function $name$arguments${docComment != null ? '\n\n$docComment' : ''}
''');
      return lsp.Hover(contents: contents, range: range);
    }
  }

  Future<lsp.Hover?> _mixinHover(sass.IncludeRule node, TextDocument document,
      lsp.Position position) async {
    var name = node.nameSpan.text;
    var range = toRange(node.nameSpan);

    var definition = await goToDefinition(document, range.start);
    if (definition == null) {
      return null;
    }

    var definitionDocument = ls.cache.getDocument(definition.uri);
    if (definitionDocument == null) {
      return null;
    }

    var definitionStylesheet = ls.parseStylesheet(definitionDocument);
    var path = getNodePathAtOffset(
      definitionStylesheet,
      definitionDocument.offsetAt(definition.range.start),
    );

    String? docComment;
    String arguments = '';
    for (var i = 0; i < path.length; i++) {
      var node = path.elementAt(i);
      if (node is sass.MixinRule) {
        docComment = node.comment?.docComment;
        arguments = '(${node.arguments.toString()})';
        break;
      }
    }

    if (supportsMarkdown()) {
      var contents = asMarkdown('''
```${document.languageId}
@mixin $name$arguments
```${docComment != null ? '\n____\n${docComment.replaceAll('\n', '\n\n')}\n\n' : ''}
''');
      return lsp.Hover(contents: contents, range: range);
    } else {
      var contents = asPlaintext('''
@mixin $name$arguments${docComment != null ? '\n\n$docComment' : ''}
''');
      return lsp.Hover(contents: contents, range: range);
    }
  }
}
