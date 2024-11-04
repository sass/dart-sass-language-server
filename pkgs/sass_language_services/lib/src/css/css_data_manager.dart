import 'css_at_directive.dart';
import 'css_property.dart';
import 'css_pseudo_class.dart';
import 'css_pseudo_element.dart';
import 'css_units.dart';
import 'element_selectors.dart';

class CssDataManager {
  final _propertiesSet = <String, CssProperty>{};
  final _atDirectivesSet = <String, CssAtDirective>{};
  final _pseudoClassesSet = <String, CssPseudoClass>{};
  final _pseudoElementsSet = <String, CssPseudoElement>{};

  final List<CssProperty> properties;
  final List<CssAtDirective> atDirectives;
  final List<CssPseudoClass> pseudoClasses;
  final List<CssPseudoElement> pseudoElements;

  final cssUnits = CssUnits();
  final elementSelectors = ElementSelectors();

  CssDataManager(this.properties, this.atDirectives, this.pseudoClasses,
      this.pseudoElements) {
    for (var entry in properties) {
      _propertiesSet[entry.name] = entry;
    }
    for (var entry in atDirectives) {
      _atDirectivesSet[entry.name] = entry;
    }
    for (var entry in pseudoClasses) {
      _pseudoClassesSet[entry.name] = entry;
    }
    for (var entry in pseudoElements) {
      _pseudoElementsSet[entry.name] = entry;
    }
  }

  CssProperty? getProperty(String name) {
    return _propertiesSet[name];
  }

  CssAtDirective? getAtDirective(String name) {
    return _atDirectivesSet[name];
  }

  CssPseudoClass? getPseudoClass(String name) {
    return _pseudoClassesSet[name];
  }

  CssPseudoElement? getPseudoElement(String name) {
    return _pseudoElementsSet[name];
  }
}
