import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_api/sass_api.dart' as sass;

import '../../utils/sass_lsp_utils.dart';
import '../node_at_offset_visitor.dart';

class SelectionRangesVisitor extends NodeAtOffsetVisitor {
  final ranges = <lsp.SelectionRange>[];

  SelectionRangesVisitor(super._offset);

  @override
  void processCandidate(sass.AstNode node) {
    ranges.add(lsp.SelectionRange(range: toRange(node.span)));

    if (node is sass.Declaration) {
      ranges.add(lsp.SelectionRange(range: toRange(node.name.span)));
    }
  }
}
