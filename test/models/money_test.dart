import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/models/money.dart';

void main() {
  group('formatRs', () {
    test('whole rupees have no decimals', () {
      expect(formatRs(45000), 'Rs. 450');
      expect(formatRs(0), 'Rs. 0');
    });
    test('cents are shown with two digits', () {
      expect(formatRs(45050), 'Rs. 450.50');
      expect(formatRs(45005), 'Rs. 450.05');
    });
    test('thousands get a comma', () => expect(formatRs(260000), 'Rs. 2,600'));
    test('negative amounts', () => expect(formatRs(-1500), '-Rs. 15'));
  });

  group('parseRs', () {
    test('plain and decimal amounts', () {
      expect(parseRs('450'), 45000);
      expect(parseRs('450.5'), 45050);
      expect(parseRs('450.50'), 45050);
      expect(parseRs('0.29'), 29); // no floating point rounding
    });
    test('receipt formats', () {
      expect(parseRs('1,250.00'), 125000);
      expect(parseRs('Rs. 450'), 45000);
      expect(parseRs('Rs.450/='), 45000);
      expect(parseRs('LKR 99.99'), 9999);
    });
    test('invalid input returns null', () {
      expect(parseRs(''), isNull);
      expect(parseRs('abc'), isNull);
      expect(parseRs('-5'), isNull);
      expect(parseRs('1.234'), isNull);
    });
  });

  test('formatPercent', () {
    expect(formatPercent(5000), '50%');
    expect(formatPercent(1250), '12.5%');
    expect(formatPercent(3333), '33.33%');
  });
}
