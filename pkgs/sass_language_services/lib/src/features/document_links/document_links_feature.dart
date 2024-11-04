import 'dart:convert';

import 'package:sass_api/sass_api.dart' as sass;
import 'package:sass_language_services/sass_language_services.dart';

import '../../utils/node_utils.dart';
import '../../utils/uri_utils.dart';
import '../language_feature.dart';
import 'document_link_visitor.dart';

final schemeRegex = RegExp(r'^\w+:\/\/');
final sassExt = RegExp(r'\.s[ac]ss$');

class DocumentLinksFeature extends LanguageFeature {
  DocumentLinksFeature({required super.ls});

  Future<List<StylesheetDocumentLink>> findDocumentLinks(
      TextDocument document) async {
    final cached = ls.cache.getDocumentLinks(document);
    if (cached != null) {
      return cached;
    }

    List<StylesheetDocumentLink> resolvedLinks = [];

    final stylesheet = ls.parseStylesheet(document);
    final context = getDocumentContext();
    final rootFolder = context.resolveReference('/', document.uri);

    // TODO: if sass_api exports [importers](https://github.com/sass/dart-sass/tree/d58e2191b67cd6d20db335c280950e641be3f0d4/lib/src/importer)
    // we can probably remove most of this implementation.
    var unresolvedLinks = _findUnresolvedLinks(document, stylesheet);
    for (var (link, isSassLink) in unresolvedLinks) {
      if (link.target == null) {
        continue;
      }

      final target = link.target.toString();
      if (target.startsWith('data:')) {
        continue;
      }

      if (target.startsWith('sass:')) {
        // target is not included since this doesn't link to a file on disk
        // TODO: https://github.com/sass/dart-sass-language-server/issues/5#issuecomment-2452932807
        resolvedLinks.add(StylesheetDocumentLink(
            type: link.type,
            range: link.range,
            data: link.data,
            tooltip: link.tooltip,
            namespace: link.namespace,
            prefix: link.prefix,
            hiddenVariables: link.hiddenVariables,
            shownVariables: link.shownVariables,
            hiddenMixinsAndFunctions: link.hiddenMixinsAndFunctions,
            shownMixinsAndFunctions: link.shownMixinsAndFunctions));
        continue;
      }

      if (schemeRegex.hasMatch(target)) {
        resolvedLinks.add(link);
        continue;
      }

      var resolved = await _resolveReference(
          link.target as Uri, document.uri, rootFolder, isSassLink);
      if (resolved == null) {
        continue;
      }

      // For monorepos, resolve the real path behind a symlink, since multiple links in `node_modules/` can point to the same file.
      // Take this initial performance hit to maximise cache hits and provide better results for projects using symlinks.
      resolved = await ls.fs.realPath(resolved);

      // lsp.DocumentLink.target is marked as final, so we make a new one
      resolvedLinks.add(StylesheetDocumentLink(
        type: link.type,
        target: resolved,
        range: link.range,
        data: link.data,
        tooltip: link.tooltip,
        namespace: link.namespace,
        prefix: link.prefix,
        hiddenVariables: link.hiddenVariables,
        shownVariables: link.shownVariables,
        hiddenMixinsAndFunctions: link.hiddenMixinsAndFunctions,
        shownMixinsAndFunctions: link.shownMixinsAndFunctions,
      ));
    }

    ls.cache.setDocumentLinks(document, resolvedLinks);
    return resolvedLinks;
  }

  List<UnresolvedLinkData> _findUnresolvedLinks(
      TextDocument document, sass.Stylesheet stylesheet) {
    final visitor = DocumentLinkVisitor();
    stylesheet.accept(visitor);
    return visitor.unresolvedLinks;
  }

  Future<Uri?> _resolveReference(
      Uri target, Uri document, Uri rootFolder, bool isSassLink) async {
    if (target.scheme == 'pkg') {
      return _resolvePkgModuleReference(target, document, rootFolder);
    }

    // Following Webpack's css-loader and sass-loader's (now deprecated) convention,
    // if an import path starts with tilde then use Node's module resolution
    // unless it starts with '~/' which points to the user's home directory.
    if (target.path[0] == '~' && target.path[1] != '/') {
      target = target.replace(path: target.path.substring(1));
      return _mapReference(
          await _resolveModuleReference(target, document, rootFolder),
          isSassLink);
    }

    final ref = await _mapReference(document.resolveUri(target), isSassLink);

    // Following Webpack's sass-loader's resolving of import at-rules,
    // the loader will first try to resolve the link as a relative path,
    // then as a path from inside node_modules.
    if (!target.path.endsWith('.css')) {
      if (ref != null && await ls.fs.exists(ref)) {
        return ref;
      }

      final moduleReference =
          await _resolveModuleReference(target, document, rootFolder);
      if (moduleReference != null) {
        final mapped = await _mapReference(moduleReference, isSassLink);
        if (mapped != null) {
          return mapped;
        }
      }
    }

    // Try resolving the reference from loadPaths or importAliases
    if (ref != null && await ls.fs.exists(ref) == false) {
      // Alias may point to a specific file
      if (ls.configuration.workspace.importAliases.containsKey(target.path)) {
        final aliasTarget =
            ls.configuration.workspace.importAliases[target.path];
        return _mapReference(joinPath(rootFolder, [aliasTarget!]), isSassLink);
      }

      // Or a directory. Alias must end in / in this case.
      final firstSlash = target.path.indexOf('/');
      final alias = target.path.substring(0, firstSlash + 1);
      if (ls.configuration.workspace.importAliases.containsKey(alias)) {
        var aliasTarget = ls.configuration.workspace.importAliases[alias];
        aliasTarget = aliasTarget!.substring(0, aliasTarget.length - 1);

        var newTarget = joinPath(rootFolder, [aliasTarget]);
        newTarget =
            joinPath(newTarget, [target.path.substring(alias.length - 1)]);

        return _mapReference(newTarget, isSassLink);
      }

      for (var loadPath in ls.configuration.workspace.loadPaths) {
        final newPath = joinPath(rootFolder, [loadPath, target.path]);
        final ref = await _mapReference(newPath, isSassLink);
        if (ref != null && await ls.fs.exists(ref)) {
          return ref;
        }
      }
    }

    // Return the input ref, it might not exist anywhere.
    return ref;
  }

  Future<Uri?> _mapReference(Uri? target, bool isSassLink) async {
    if (target != null && isSassLink) {
      var variations = _toPathVariations(target);
      for (var variation in variations) {
        if (await ls.fs.exists(variation)) {
          return variation;
        }
      }
    }
    return target;
  }

  List<Uri> _toPathVariations(Uri target) {
    if (target.path.endsWith('.css') ||
        target.path.endsWith('.scss') ||
        target.path.endsWith('.sass')) {
      return [target];
    }

    // If a link is like a/, try resolving a/index.scss and a/_index.scss
    // and likewise for .sass
    if (target.path.endsWith('/')) {
      return [
        target.replace(path: '${target.path}_index.scss'),
        target.replace(path: '${target.path}index.scss'),
        target.replace(path: '${target.path}_index.sass'),
        target.replace(path: '${target.path}index.sass'),
      ];
    }

    final base = basename(target.path);
    if (base.startsWith('_')) {
      return [
        target.replace(path: '${target.path}.scss'),
        target.replace(path: '${target.path}.sass'),
      ];
    }

    final dir = dirname(target);
    return [
      joinPath(dir, ['_$base.scss']),
      joinPath(dir, ['$base.scss']),
      target.replace(path: '${target.path}/_index.scss'),
      target.replace(path: '${target.path}/index.scss'),
      joinPath(dir, ['_$base.sass']),
      joinPath(dir, ['$base.sass']),
      target.replace(path: '${target.path}/_index.sass'),
      target.replace(path: '${target.path}/index.sass'),
    ];
  }

  Future<Uri?> _resolveModuleReference(
      Uri target, Uri document, Uri rootFolder) async {
    if (document.scheme != 'file') {
      return null;
    }

    final documentFolder = dirname(document);

    final moduleName = getModuleNameFromPath(target.path);
    final modulePath =
        await _resolvePathToModule(moduleName, documentFolder, rootFolder);
    if (modulePath != null) {
      final pathWithinModule = target.path.substring(moduleName.length + 1);
      return joinPath(modulePath, [pathWithinModule]);
    }

    return null;
  }

  Future<Uri?> _resolvePathToModule(
      String moduleName, Uri documentFolder, Uri rootFolder) async {
    final packageJson =
        joinPath(documentFolder, ['node_modules', moduleName, 'package.json']);
    if (await ls.fs.exists(packageJson)) {
      return dirname(packageJson);
    } else if (documentFolder.path.startsWith(rootFolder.path) &&
        documentFolder.path != rootFolder.path) {
      return _resolvePathToModule(
          moduleName, dirname(documentFolder), rootFolder);
    }
    return null;
  }

  Future<Uri?> _resolvePkgModuleReference(
      Uri target, Uri document, Uri rootFolder) async {
    final bareTarget = target.path.replaceFirst('pkg:', '');
    final moduleName = bareTarget.contains('/')
        ? getModuleNameFromPath(bareTarget)
        : bareTarget;
    final documentFolder = dirname(document);

    final modulePath =
        await _resolvePathToModule(moduleName, documentFolder, rootFolder);
    if (modulePath == null) {
      return null;
    }

    // Since submodule exports import strings don't match the file system
    // we need the contents of package.json in order to look up the correct path.
    dynamic packageJson;
    try {
      final contents =
          await ls.fs.readFile(joinPath(modulePath, ['package.json']));
      packageJson = jsonDecode(contents);
      assert(packageJson is Map);
    } catch (e) {
      return null;
    }

    final subpath = bareTarget.substring(moduleName.length + 1);
    if (packageJson['exports'] is Map) {
      if (subpath.isEmpty) {
        // exports may look like { "sass": "./_index.scss" } or { ".": { "sass": "./_index.scss" } }
        final rootExport = packageJson['exports']['.'] is Map
            ? packageJson['exports']['.']
            : packageJson['exports'];

        // Look for the default/index export
        final entrypoint = rootExport is Map
            ? rootExport['sass'] ?? rootExport['style'] ?? rootExport['default']
            : null;

        // the 'default' entry can be whatever, typically .js – confirm it looks like Sass
        if (entrypoint is String && sassExt.hasMatch(entrypoint)) {
          return joinPath(modulePath, [entrypoint]);
        }
      } else {
        // The import string may be with or without a file extension.
        // Likewise the exports entry. Look up both paths (i. e. both key and value).
        // However, they need to be relative (start with ./).
        final subpathNoExt = sassExt.hasMatch(subpath)
            ? './${subpath.replaceFirst(sassExt, '')}'
            : './$subpath';
        final subpathScss = sassExt.hasMatch(subpath)
            ? './${subpath.replaceFirst(sassExt, '.scss')}'
            : './$subpath.scss';
        final subpathSass = sassExt.hasMatch(subpath)
            ? './${subpath.replaceFirst(sassExt, '.sass')}'
            : './$subpath.sass';

        final subpathExport = packageJson['exports'][subpathNoExt] ??
            packageJson['exports'][subpathScss] ??
            packageJson['exports'][subpathSass];
        if (subpathExport is Map) {
          final entrypoint = subpathExport['sass'] ??
              subpathExport['style'] ??
              subpathExport['default'];

          if (entrypoint is String && sassExt.hasMatch(entrypoint)) {
            return joinPath(modulePath, [entrypoint]);
          }
        } else {
          // We have a subpath, but found no matches on direct lookup.
          // It may be a [subpath pattern](https://nodejs.org/api/packages.html#subpath-patterns).
          for (var MapEntry(key: pattern, value: subpathExport)
              in (packageJson['exports'] as Map).entries) {
            if (pattern is String) {
              if (pattern.contains('*')) {
                final re = RegExp(pattern
                    .replaceAll('./', '\\./')
                    .replaceFirst('.scss', '')
                    .replaceFirst('.sass', '')
                    .replaceAll('*', '(.+)'));
                final match = re.firstMatch(subpathNoExt);
                if (match != null) {
                  final entrypoint = subpathExport['sass'] ??
                      subpathExport['style'] ??
                      subpathExport['default'];

                  if (entrypoint is String && sassExt.hasMatch(entrypoint)) {
                    // If the left-hand side is a pattern, so is the right-hand side.
                    // Replace the pattern with the match from our regexp capture group above.
                    final expanded = entrypoint.replaceFirst('*', match[1]!);
                    return joinPath(modulePath, [expanded]);
                  }
                }
              } else {
                // Not a pattern
                continue;
              }
            } else {
              // Not a pattern
              continue;
            }
          }
        }
      }
    } else if (subpath.isEmpty &&
        (packageJson['sass'] is String || packageJson['style'] is String)) {
      // Fall back to a direct lookup on `sass` and `style` on package root
      var entrypoint = (packageJson['sass'] ?? packageJson['style']) as String;
      return joinPath(modulePath, [entrypoint]);
    }

    return null;
  }
}
