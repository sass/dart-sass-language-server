Uri filePathToUri(String path) {
  var safePath = path.startsWith('/') ? path : '/$path';
  var uri = Uri.parse('file://${safePath.toLowerCase()}');
  return uri;
}
