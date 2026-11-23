import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/domain/category_suggester.dart';

void main() {
  String s(String name) => CategorySuggester.suggest(name);

  test('Appendix A items get the expected categories', () {
    expect(s('Rice'), 'groceries');
    expect(s('Shampoo'), 'personal_care');
    expect(s('Panadol'), 'medicine');
    expect(s('Milk'), 'groceries');
    expect(s('Detergent'), 'household');
  });

  test('works with OCR-style receipt names', () {
    expect(s('PANADOL 500MG 12S'), 'medicine');
    expect(s('KEELLS SAMBA RICE 5KG'), 'groceries');
    expect(s('COCA COLA 1.5L'), 'drinks');
    expect(s('MUNCHEE SUPER CREAM CRACKER'), 'snacks');
    expect(s('Chicken Kottu'), 'food');
    expect(s('SUNLIGHT SOAP 110G'), 'household');
    expect(s('Soup'), 'food');
  });

  test('matches whole words from the start only', () {
    expect(s('Steak knife'), 'other'); // no 'tea'
    expect(s('Milkmaid'), 'groceries');
  });

  test('unknown or empty names are Other', () {
    expect(s('ZX-4410'), 'other');
    expect(s(''), 'other');
  });
}
