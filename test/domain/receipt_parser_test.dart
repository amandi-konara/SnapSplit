import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/domain/receipt_parser.dart';

void main() {
  test('supermarket bill with codes, quantities and a net total', () {
    final r = ReceiptParser.parse([
      'KEELLS SUPER',
      'No 45, Galle Road, Colombo 03',
      'Tel: 011 2345678',
      'Date: 02/10/2026   Time: 14:05',
      'Invoice No: 000123',
      '001 SAMBA RICE 5KG        500.00',
      '002 SHAMPOO 180ML         850.00',
      'PANADOL 500MG',
      '  1.000 x 250.00          250.00',
      'FRESH MILK 1L    2 x      300.00',
      'DETERGENT POWDER 1KG      700.00',
      'SUB TOTAL               2,600.00',
      'NET TOTAL               2,600.00',
      'CASH                    3,000.00',
      'BALANCE                   400.00',
      'Thank you, come again!',
    ]);
    expect(r.storeName, 'Keells');
    expect(r.date, DateTime(2026, 10, 2));
    expect(r.totalCents, 260000);
    expect(r.items.map((i) => i.name), [
      'Samba Rice 5kg',
      'Shampoo 180ml',
      'Panadol 500mg',
      'Fresh Milk 1l',
      'Detergent Powder 1kg',
    ]);
    expect(r.items.map((i) => i.amountCents), [
      50000,
      85000,
      25000,
      30000,
      70000,
    ]);
  });

  test('small restaurant bill with an unknown store', () {
    final r = ReceiptParser.parse([
      'Green Leaf Cafe',
      '2026-11-13',
      'Chicken Kottu 950.00',
      'Lime Juice 350.00',
      'Service Charge 10% 130.00',
      'TOTAL 1,430.00',
    ]);
    expect(r.storeName, 'Green Leaf Cafe');
    expect(r.date, DateTime(2026, 11, 13));
    expect(r.totalCents, 143000);
    expect(r.items.length, 2);
    expect(r.items.first.name, 'Chicken Kottu');
  });

  test('total on the row under its label', () {
    final r = ReceiptParser.parse(['Soup 450.00', 'TOTAL', '450.00']);
    expect(r.totalCents, 45000);
    expect(r.items.single.amountCents, 45000);
  });

  test('discount rows are skipped', () {
    final r = ReceiptParser.parse([
      'BISCUIT 200.00',
      'DISCOUNT -20.00',
      'TOTAL 180.00',
    ]);
    expect(r.items.single.name, 'Biscuit');
  });

  test('nothing readable gives an empty result', () {
    final r = ReceiptParser.parse(['', '###', '12:30']);
    expect(r.items, isEmpty);
    expect(r.totalCents, isNull);
    expect(r.date, isNull);
  });
}
