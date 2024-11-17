import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:sass_language_services/sass_language_services.dart';
import 'package:sass_language_services/src/features/find_references/find_references_visitor.dart';
import 'package:sass_language_services/src/features/go_to_definition/go_to_definition_feature.dart';

import '../../sass/sass_data.dart';
import '../go_to_definition/definition.dart';
import 'reference.dart';

class FindReferencesFeature extends GoToDefinitionFeature {
  FindReferencesFeature({required super.ls});

  Future<List<lsp.Location>> findReferences(TextDocument document,
      lsp.Position position, lsp.ReferenceContext context) async {
    var references = await internalFindReferences(document, position, context);
    return references.references.map((r) => r.location).toList();
  }

  Future<({Definition? definition, List<Reference> references})>
      internalFindReferences(TextDocument document, lsp.Position position,
          lsp.ReferenceContext context) async {
    var references = <Reference>[];
    var definition = await internalGoToDefinition(document, position);
    if (definition == null) {
      return (definition: definition, references: references);
    }

    String? builtin;
    if (definition.location == null) {
      // If we don't have a location we might be dealing with a built-in.
      var sassData = SassData();
      for (var module in sassData.modules) {
        for (var function in module.functions) {
          if (function.name == definition.name) {
            builtin = function.name;
            break;
          }
        }
        for (var variable in module.variables) {
          if (variable.name == definition.name) {
            builtin = variable.name;
            break;
          }
        }
        if (builtin != null) {
          break;
        }
      }
    }

    if (definition.location == null && builtin == null) {
      return (definition: definition, references: references);
    }

    var name = builtin ?? definition.name;

    var candidates = <Reference>[];
    // Go through all documents with a visitor.
    // For each document, collect candidates that match the definition name.
    for (var document in ls.cache.getDocuments()) {
      var stylesheet = ls.parseStylesheet(document);
      var visitor = FindReferencesVisitor(
        document,
        name,
        includeDeclaration: context.includeDeclaration,
      );
      stylesheet.accept(visitor);
      candidates.addAll(visitor.candidates);

      // Go through all candidates and add matches to references.
      // A match is a candidate with the same name, referenceKind,
      // and whose definition is the same as the definition of the
      // symbol at [position].
      for (var candidate in candidates) {
        if (builtin case var name?) {
          if (name.contains(candidate.name)) {
            references.add(
              Reference(
                name: candidate.name,
                kind: candidate.kind,
                location: candidate.location,
                defaultBehavior: true,
              ),
            );
          }
        } else {
          if (candidate.kind != definition.kind) {
            continue;
          }

          var candidateIsDefinition = _isSameLocation(
            candidate.location,
            definition.location!,
          );

          if (!context.includeDeclaration && candidateIsDefinition) {
            continue;
          } else if (candidateIsDefinition) {
            references.add(candidate);
            continue;
          }

          // Find the definition of the candidate and compare it
          // to the definition of the symbol at [position]. If
          // the two definitions are the same, we have a reference.
          var candidateDefinition = await internalGoToDefinition(
            document,
            position,
          );

          if (candidateDefinition != null &&
              candidateDefinition.location != null) {
            if (_isSameLocation(
              candidateDefinition.location!,
              definition.location!,
            )) {
              references.add(candidate);
              continue;
            }
          }
        }
      }
    }

    return (definition: definition, references: references);
  }

  bool _isSameLocation(lsp.Location a, lsp.Location b) {
    return a.uri.toString() == b.uri.toString() &&
        a.range.start.line == b.range.start.line &&
        a.range.start.character == b.range.start.character &&
        a.range.end.line == b.range.end.line &&
        a.range.end.character == b.range.end.character;
  }
}