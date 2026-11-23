import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/data/fake/sample_data.dart';
import 'package:snapsplit/models/models.dart';

void main() {
  final keells = SampleData.receipts().firstWhere((r) => r.id == 'r-keells');

  test('Appendix A receipt totals Rs. 2,600 and matches the printed total', () {
    expect(keells.totalCents, 260000);
    expect(keells.printedTotalDifference, 0);
  });

  test('person totals add up to the receipt total', () {
    final totals = keells.totalsByPerson;
    expect(totals.values.reduce((a, b) => a + b), keells.totalCents);
    expect(totals['p-amandi'], 25000 + 85000 + 15000 + 28000);
    expect(totals['p-mom'], 25000 + 25000 + 15000 + 42000);
  });

  test('category totals', () {
    expect(keells.totalsByCategory['groceries'], 80000);
    expect(keells.totalsByCategory['medicine'], 25000);
  });

  test('sample receipts are fully assigned', () {
    for (final r in SampleData.receipts()) {
      expect(r.isFullyAssigned, isTrue, reason: r.storeName);
    }
  });

  test('unassigned amount on an item', () {
    const item = ReceiptItem(
      id: 'x',
      name: 'Soup',
      amountCents: 45000,
      assignments: [Assignment(personId: 'a', allocatedCents: 20000)],
    );
    expect(item.unassignedCents, 25000);
    expect(item.isFullyAssigned, isFalse);
  });

  test('JSON round trip keeps everything', () {
    final copy = Receipt.fromJson(keells.toJson());
    expect(copy, keells);
  });
}
