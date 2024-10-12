enum ProviderEntryType { unknown, file, directory, link }

class ProviderFileStat {
  final ProviderEntryType type;
  final int ctime;
  final int mtime;
  final int size;

  const ProviderFileStat(this.type, this.ctime, this.mtime, this.size);
}

abstract class FileSystemProvider {
  /// Check if the file at the given [uri] exists or not.
  Future<bool> exists(Uri uri);

  /// Run a search in the file system for [pattern], optionally [exclude] patterns.
  Future<Iterable<Uri>> findFiles(String pattern, List<String>? exclude);

  /// Get the contents of the file at [uri] as a UTF-8-encoded string.
  Future<String> readFile(Uri uri);

  /// Get a list of entries in the directory at [uri]. Each entry includes its name and a [ProviderEntryType].
  Stream<(String, ProviderEntryType)> readDirectory(Uri uri);

  /// Get [ProviderFileStat] for the file at [uri].
  Future<ProviderFileStat> stat(Uri uri);

  /// Get the real path of a file in case of a symbolic link [ProviderEntryType].
  Future<Uri> realPath(Uri uri);
}
