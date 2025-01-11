import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/selection_ranges/selection_ranges_visitor.dart';
import 'package:sass_language_services/src/utils/sass_lsp_utils.dart';

import '../language_feature.dart';

class SelectionRangesFeature extends LanguageFeature {
  SelectionRangesFeature({required super.ls});

  List<lsp.SelectionRange> getSelectionRanges(
      TextDocument document, List<lsp.Position> positions) {
    var stylesheet = ls.parseStylesheet(document);

    var result = <lsp.SelectionRange>[];

    for (var position in positions) {
      var visitor = SelectionRangesVisitor(
        document.offsetAt(position),
      );
      stylesheet.accept(visitor);

      var ranges = visitor.ranges;
      lsp.SelectionRange? current;
      for (var i = ranges.length - 1; i >= 0; i--) {
        var range = ranges[i];

        // Avoid duplicates
        if (current != null && isSameRange(current.range, range.range)) {
          continue;
        }

        current = lsp.SelectionRange(
          range: range.range,
          parent: current,
        );
      }
      if (current == null) {
        result.add(
          lsp.SelectionRange(
            range: lsp.Range(start: position, end: position),
          ),
        );
      }
      result.add(current!);
    }

    return result;
  }
}
