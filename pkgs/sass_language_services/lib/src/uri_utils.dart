import 'package:path/path.dart' as p;

final context = p.Context(style: p.Style.url);

Uri joinPath(Uri base, List<String> segments) {
  var context = p.Context(style: p.Style.url, current: base.path);
  var path = context.normalize(context.joinAll([base.path, ...segments]));
  return base.replace(path: path);
}

String basename(String path) => context.basename(path);

Uri dirname(Uri uri) {
  if (uri.path.isEmpty || uri.path == '/') {
    return uri;
  }

  var path = context.dirname(uri.path);
  if (path.length == 1 && path[0] == '.') {
    path = '';
  }

  return uri.replace(path: path);
}

String extension(String path) => context.extension(path);
