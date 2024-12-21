import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';

import '../language_feature.dart';
import '../node_at_offset_visitor.dart';
import './completion_context.dart';
import './completion_list.dart';

class CompletionFeature extends LanguageFeature {
  CompletionFeature({required super.ls});

  Future<lsp.CompletionList> doComplete(
      TextDocument document, lsp.Position position) async {
    var configuration = getLanguageConfiguration(document).completion;

    var offset = document.offsetAt(position);
    var (lineBeforePosition, currentWord) = _getLineContext(document, offset);

    var defaultReplaceRange = lsp.Range(
      start: lsp.Position(
        line: position.line,
        character: position.character - currentWord.length,
      ),
      end: position,
    );

    var result = CompletionList(
      isIncomplete: false,
      items: [],
      itemDefaults: lsp.CompletionListItemDefaults(
        editRange: lsp.Either2.t2(defaultReplaceRange),
      ),
    );

    var stylesheet = ls.parseStylesheet(document);
    var path = getNodePathAtOffset(stylesheet, offset);

    var context = CompletionContext(
      offset: offset,
      position: position,
      currentWord: currentWord,
      defaultReplaceRange: defaultReplaceRange,
      document: document,
      configuration: configuration,
      stylesheet: stylesheet,
      lineBeforePosition: lineBeforePosition,
    );

    for (var i = path.length; i >= 0; i--) {
      var node = path[i];
      if (node is sass.Declaration) {
        _declarationCompletion(node, context, result);
      } else if (node is sass.SimpleSelector) {
        _selectorCompletion(node, context, result);
      } else if (node is sass.Interpolation) {
        var isExtendRule = false;
        for (var j = i; j >= 0; j--) {
          var parent = path[j];
          if (parent is sass.ExtendRule) {
            isExtendRule = true;
            break;
          }
        }
        if (isExtendRule) {
          _extendRuleCompletion(node, context, result);
        } else {
          _interpolationCompletion(node, context, result);
        }
      } else if (node is sass.ArgumentInvocation) {
        _argumentInvocationCompletion(node, context, result);
      } else if (node is sass.StyleRule) {
        _styleRuleCompletion(node, context, result);
      } else if (node is sass.PlaceholderSelector) {
        _placeholderSelectorCompletion(node, context, result);
      } else if (node is sass.VariableDeclaration) {
        _variableDeclarationCompletion(node, context, result);
      } else if (node is sass.FunctionRule) {
        _functionRuleCompletion(node, context, result);
      } else if (node is sass.MixinRule) {
        _mixinRuleCompletion(node, context, result);
      } else if (node is sass.SupportsRule) {
        _supportsRuleCompletion(node, context, result);
      } else if (node is sass.SupportsCondition) {
        _supportsConditionCompletion(node, context, result);
      } else if (node is sass.StringExpression) {
        var isSassDependency = false;
        var isImportRule = false;
        for (var j = i; j >= 0; j--) {
          var parent = path[j];
          if (parent is sass.SassDependency) {
            isSassDependency = true;
            break;
          } else if (parent is sass.ImportRule) {
            isImportRule = true;
            break;
          }
        }
        if (isSassDependency) {
          await _sassDependencyCompletion(node, context, result);
        } else if (isImportRule) {
          await _importRuleCompletion(node, context, result);
        }
      } else if (node is sass.SilentComment) {
        _commentCompletion(node, context, result);
      } else {
        continue;
      }

      if (result.items.isNotEmpty || context.offset > node.span.start.offset) {
        return _send(result);
      }
    }

    _stylesheetCompletion(context, result);
    return _send(result);
  }

  lsp.CompletionList _send(CompletionList result) {
    return lsp.CompletionList(
      isIncomplete: result.isIncomplete,
      items: result.items,
      itemDefaults: result.itemDefaults,
    );
  }

  /// Get the current word and the contents of the line before [offset].
  (String, String) _getLineContext(TextDocument document, int offset) {
    var text = document.getText();

    // From offset, go back until hitting a newline
    var i = offset - 1;
    var codeUnit = text.codeUnitAt(i);
    const lineFeed = 10; // \n
    const carriageReturn = 13; // \r
    while (codeUnit != lineFeed && codeUnit != carriageReturn) {
      i--;
      codeUnit = text.codeUnitAt(i);
    }
    var lineBeforePosition = text.substring(i + 1, offset);

    // From offset, go back until hitting a word delimiter
    i = offset - 1;
    var wordDelimiters = ' \t\n\r":[()]}/,\''.codeUnits;
    while (i >= 0 && !wordDelimiters.contains(text.codeUnitAt(i))) {
      i--;
    }
    var currentWord = text.substring(i + 1, offset);

    return (lineBeforePosition, currentWord);
  }

  void _declarationCompletion(sass.Declaration node, CompletionContext context,
      CompletionList result) {}

  void _interpolationCompletion(sass.Interpolation node,
      CompletionContext context, CompletionList result) {}

  void _extendRuleCompletion(sass.Interpolation node, CompletionContext context,
      CompletionList result) {}

  void _selectorCompletion(sass.SimpleSelector node, CompletionContext context,
      CompletionList result) {}

  void _argumentInvocationCompletion(sass.ArgumentInvocation node,
      CompletionContext context, CompletionList result) {}

  void _styleRuleCompletion(
      sass.StyleRule node, CompletionContext context, CompletionList result) {}

  void _variableDeclarationCompletion(sass.VariableDeclaration node,
      CompletionContext context, CompletionList result) {}

  void _functionRuleCompletion(sass.FunctionRule node,
      CompletionContext context, CompletionList result) {}

  void _mixinRuleCompletion(
      sass.MixinRule node, CompletionContext context, CompletionList result) {}

  void _supportsRuleCompletion(sass.SupportsRule node,
      CompletionContext context, CompletionList result) {}

  void _supportsConditionCompletion(sass.SupportsCondition node,
      CompletionContext context, CompletionList result) {}

  Future<void> _sassDependencyCompletion(sass.StringExpression node,
      CompletionContext context, CompletionList result) async {}

  Future<void> _importRuleCompletion(sass.StringExpression node,
      CompletionContext context, CompletionList result) async {}

  void _stylesheetCompletion(
      CompletionContext context, CompletionList result) {}

  void _commentCompletion(sass.SilentComment node, CompletionContext context,
      CompletionList result) {}

  void _placeholderSelectorCompletion(sass.PlaceholderSelector node,
      CompletionContext context, CompletionList result) {}
}
