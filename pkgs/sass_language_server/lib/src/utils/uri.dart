Uri filePathToUri(String path) {
  var safePath = path.startsWith('/') ? path : '/$path';
  var uri = Uri.parse('file://$safePath');
  return uri;
}
