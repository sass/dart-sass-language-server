import 'package:lsp_server/lsp_server.dart';
import 'package:test/test.dart';

class AtLine extends CustomMatcher {
  AtLine(Object? valueOrMatcher)
      : super('Position at line', 'line', valueOrMatcher);

  featureValueOf(actual) => (actual as Position).line;
}

class AtCharacter extends CustomMatcher {
  AtCharacter(Object? valueOrMatcher)
      : super('Position at character', 'character', valueOrMatcher);

  featureValueOf(actual) => (actual as Position).character;
}

class StartsAtLine extends CustomMatcher {
  StartsAtLine(Object? valueOrMatcher)
      : super('Range starts at line', 'line', valueOrMatcher);
  featureValueOf(actual) => (actual as Range).start.line;
}

class StartsAtCharacter extends CustomMatcher {
  StartsAtCharacter(Object? valueOrMatcher)
      : super('Range starts at character', 'character', valueOrMatcher);
  featureValueOf(actual) => (actual as Range).start.character;
}

class EndsAtLine extends CustomMatcher {
  EndsAtLine(Object? valueOrMatcher)
      : super('Range ends at line', 'line', valueOrMatcher);
  featureValueOf(actual) => (actual as Range).end.line;
}

class EndsAtCharacter extends CustomMatcher {
  EndsAtCharacter(Object? valueOrMatcher)
      : super('Range ends at character', 'character', valueOrMatcher);
  featureValueOf(actual) => (actual as Range).end.character;
}
