import 'package:path/path.dart' as p;

final context = p.Context(style: p.Style.url);

Uri joinPath(Uri base, List<String> segments) {
  var path = context.normalize(context.joinAll([base.path, ...segments]));
  base.replace(path: path);
  return base;
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

  uri.replace(path: path);
  return uri;
}

String extension(String path) => context.extension(path);
