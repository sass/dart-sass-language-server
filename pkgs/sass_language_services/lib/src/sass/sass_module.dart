import 'package:sass_language_services/src/sass/sass_module_function.dart';
import 'package:sass_language_services/src/sass/sass_module_variable.dart';

class SassModule {
  final String name;
  final String description;
  final Uri reference;
  final List<SassModuleVariable> variables;
  final List<SassModuleFunction> functions;

  SassModule(this.name,
      {required this.description,
      required this.reference,
      this.variables = const [],
      this.functions = const []});
}
