import 'scope.dart';
import 'scope_visitor.dart';

class Symbols {
  final _globalScope = Scope(length: double.maxFinite.floor(), offset: 0);
}
