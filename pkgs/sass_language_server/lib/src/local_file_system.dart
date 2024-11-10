import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;
import 'package:sass_language_server/src/utils/uri.dart';
import 'package:sass_language_services/sass_language_services.dart';

class LocalFileSystem extends FileSystemProvider {
  @override
  Future<Iterable<Uri>> findFiles(String pattern,
      {String? root, List<String>? exclude}) async {
    var list = await Glob(pattern, caseSensitive: false)
        .list(
          root: root,
          // Skip links. We resolve the real path behind links in findDocumentLinks later on.
          // If we follow links here we can end up with an inflated initial list in
          // monorepos that use symlinks in node_modules.
          followLinks: false,
        )
        .toList();

    var excludeGlobs = <Glob>[];
    if (exclude != null) {
      for (var pattern in exclude) {
        excludeGlobs.add(Glob(pattern,
            caseSensitive: false, context: p.Context(style: p.Style.url)));
      }
    }

    var result = <Uri>[];
    for (var match in list) {
      var excluded = false;
      for (var glob in excludeGlobs) {
        if (glob.matches(match.uri.path)) {
          excluded = true;
          break;
        }
      }
      if (excluded) {
        continue;
      }
      result.add(match.uri);
    }

    return result;
  }

  @override
  Future<bool> exists(Uri uri) {
    var file = File(uri.toFilePath());
    return file.exists();
  }

  ProviderEntryType _toEntryType(FileStat stat) {
    switch (stat.type) {
      case FileSystemEntityType.directory:
        return ProviderEntryType.directory;
      case FileSystemEntityType.file:
        return ProviderEntryType.file;
      case FileSystemEntityType.link:
        return ProviderEntryType.link;
      case FileSystemEntityType.notFound:
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
      default:
        return ProviderEntryType.unknown;
    }
  }

  @override
  Stream<(String, ProviderEntryType)> readDirectory(Uri uri) {
    var dir = Directory(uri.toFilePath());
    return dir.list().asyncMap((e) async {
      var stat = await e.stat();
      return (e.path, _toEntryType(stat));
    });
  }

  @override
  Future<String> readFile(Uri uri) {
    var file = File(uri.toFilePath());
    return file.readAsString();
  }

  @override
  Future<Uri> realPath(Uri uri) async {
    // https://api.dart.dev/stable/3.5.3/dart-io/FileSystemEntity/resolveSymbolicLinks.html
    var path = Uri.parse('.').resolveUri(uri).toFilePath();
    if (path == '') path = '.';
    var resolved = await File(path).resolveSymbolicLinks();
    return filePathToUri(resolved);
  }

  @override
  Future<ProviderFileStat> stat(Uri uri) async {
    var file = File(uri.toFilePath());
    var stat = await file.stat();
    return ProviderFileStat(
      _toEntryType(stat),
      stat.changed.millisecondsSinceEpoch,
      stat.modified.millisecondsSinceEpoch,
      stat.size,
    );
  }
}
