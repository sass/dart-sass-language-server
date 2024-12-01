import 'package:sass_language_services/src/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  group('readable specificity', () {
    test('single ID selector', () {
      expect(readableSpecificity(1000000), equals('1, 0, 0'));
    });

    test('single class selector', () {
      expect(readableSpecificity(1000), equals('0, 1, 0'));
    });

    test('single element selector', () {
      expect(readableSpecificity(1), equals('0, 0, 1'));
    });

    test('element and class selector', () {
      expect(readableSpecificity(1001), equals('0, 1, 1'));
    });
  });
}
