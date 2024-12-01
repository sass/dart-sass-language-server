import 'dart:math';

String removeQuotes(String from) {
  return from.replaceAll('"', '').replaceAll("'", '');
}

/// Takes a base 1000 specificity value from sass_api
/// and prints a more readable variant in the 0, 0, 0
/// format.
String readableSpecificity(int specificity) {
  var string = specificity.toString();
  string = string.padLeft(9, '0');

  var firstPart = string.substring(0, 3);
  var secondPart = string.substring(3, 6);
  var thirdPart = string.substring(6);

  var first = int.parse(firstPart);
  var second = int.parse(secondPart);
  var third = int.parse(thirdPart);

  return '$first, $second, $third';
}

String getFileName(String uri) {
  var lastSlash = uri.lastIndexOf("/");
  return lastSlash == -1 ? uri : uri.substring(max(0, lastSlash + 1));
}
