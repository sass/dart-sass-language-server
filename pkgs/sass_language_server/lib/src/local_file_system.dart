import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:sass_language_services/sass_language_services.dart';

class LocalFileSystem extends FileSystemProvider {
  @override
  Future<Iterable<Uri>> findFiles(String pattern, List<String>? exclude) async {
    var matches = Glob(pattern);
    var list = await matches.list().toList();

    List<Uri> result = [];
    for (var match in list) {
      if (exclude != null) {
        var scanner = StringScanner(match.path);
        for (var pattern in exclude) {
          if (scanner.scan(pattern)) {
            continue;
          }
        }
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
    return Uri.file(resolved);
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
