import 'package:path/path.dart' as p;

final context = p.Context(style: p.Style.url);

/// Get a Node module's name from an import string.
///
/// For example, given `@scope/foo/styles/main.scss` this method returns `@scope/foo`.
String getModuleNameFromImportString(String path) {
  var normalized = context.normalize(path);
  var firstSlash = normalized.indexOf('/');
  if (firstSlash == -1) return normalized;

  // For scoped npm modules get up until the second instance of /
  // or to the end of the string for the root entry point.
  if (normalized[0] == '@') {
    var secondSlash = normalized.indexOf('/', firstSlash + 1);
    if (secondSlash == -1) return normalized;
    return normalized.substring(0, secondSlash);
  }

  // Otherwise get until the first instance of /
  return normalized.substring(0, firstSlash);
}
