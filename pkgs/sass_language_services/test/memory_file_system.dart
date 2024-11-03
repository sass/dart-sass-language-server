import 'dart:io';

import 'package:path/path.dart';
import 'package:sass_language_services/sass_language_services.dart';

class MemoryFileSystem extends FileSystemProvider {
  final _storage = <String, TextDocument>{};

  TextDocument createDocument(String content,
      {String? uri, String? languageId, int? version}) {
    var documentUri =
        Uri.file(join(Directory.current.path, uri ?? 'index.scss'));

    var document =
        TextDocument(documentUri, languageId ?? 'scss', version ?? 1, content);

    _storage[document.uri.toString()] = document;
    return document;
  }

  @override
  Future<bool> exists(Uri uri) {
    return Future.value(_storage[uri.toString()] != null);
  }

  @override
  Future<Iterable<Uri>> findFiles(String pattern,
      {String? root, List<String>? exclude}) {
    return Future.value(_storage.keys.map(Uri.parse));
  }

  String _getName(String uriString) {
    if (uriString.endsWith('/')) {
      uriString = uriString.substring(0, uriString.length - 1);
    }
    return uriString.substring(uriString.lastIndexOf('/') + 1);
  }

  @override
  Stream<(String, ProviderEntryType)> readDirectory(Uri uri) {
    var toMatch = uri.toString();
    var result = <(String, ProviderEntryType)>[];

    for (var file in _storage.keys) {
      if (!file.startsWith(toMatch)) {
        continue;
      }

      var directoryIndex = file.indexOf(toMatch);
      if (directoryIndex == -1) {
        continue;
      }

      var type = ProviderEntryType.file;
      var name = _getName(file);

      var subdirectoryIndex = file.indexOf('/', toMatch.length + 1);
      if (subdirectoryIndex != -1) {
        var subdirectory = file.substring(0, subdirectoryIndex);
        var subsubdirectory = file.indexOf('/', subdirectory.length + 1);
        if (subsubdirectory != -1) {
          // Files or folders in subdirectories should not be included
          // by readDirectory.
          continue;
        }

        name = _getName(subdirectory);
        type = ProviderEntryType.directory;
      }

      result.add((name, type));
    }

    return Stream.fromIterable(result);
  }

  @override
  Future<String> readFile(Uri uri) {
    return Future.value(_storage[uri.toString()]?.getText() ?? '');
  }

  @override
  Future<Uri> realPath(Uri uri) {
    return Future.value(uri);
  }

  @override
  Future<ProviderFileStat> stat(Uri uri) {
    var file = _storage[uri.toString()];
    if (file == null) {
      return Future.value(ProviderFileStat(
        ProviderEntryType.unknown,
        -1,
        -1,
        -1,
      ));
    }

    var size = file.getText().length;
    var now = DateTime.now().millisecondsSinceEpoch;
    var ctime = now;
    var mtime = now;

    return Future.value(ProviderFileStat(
      ProviderEntryType.file,
      ctime,
      mtime,
      size,
    ));
  }
}
