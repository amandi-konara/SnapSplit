import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/domain/split_calculator.dart';
import 'package:snapsplit/models/models.dart';

Cents sum(List<Assignment> a) => a.fold(0, (s, x) => s + x.allocatedCents);

void main() {
  group('equal (T06)', () {
    test('one person pays the full amount', () {
      final a = SplitCalculator.equal(45000, ['a']);
      expect(a.single.allocatedCents, 45000);
    });

    test('two people share evenly', () {
      final a = SplitCalculator.equal(45000, ['a', 'b']);
      expect(a.map((x) => x.allocatedCents), [22500, 22500]);
    });

    test('leftover cents go to the first person', () {
      final a = SplitCalculator.equal(10000, ['a', 'b', 'c']);
      expect(a.map((x) => x.allocatedCents), [3334, 3333, 3333]);
    });

    test('no people means no assignments', () {
      expect(SplitCalculator.equal(100, []), isEmpty);
    });
  });

  group('exact (T07)', () {
    test('uses the typed amounts', () {
      final a = SplitCalculator.exact({'a': 30000, 'b': 15000});
      expect(sum(a), 45000);
      expect(a.first.share, 30000);
    });

    test('untyped amounts count as zero', () {
      final a = SplitCalculator.exact({'a': 30000, 'b': null});
      expect(a.last.allocatedCents, 0);
      expect(a.last.share, isNull);
    });
  });

  group('percentage', () {
    test('40/60 of Rs. 700', () {
      final a = SplitCalculator.percentage(70000, {'a': 4000, 'b': 6000});
      expect(a.map((x) => x.allocatedCents), [28000, 42000]);
    });

    test('rounding leftovers go to the first person at 100%', () {
      // 33.33% + 33.33% + 33.34% of Rs. 1.00
      final a = SplitCalculator.percentage(100, {
        'a': 3333,
        'b': 3333,
        'c': 3334,
      });
      expect(sum(a), 100);
      expect(a.first.allocatedCents, 34);
    });

    test('under 100% leaves a gap', () {
      final a = SplitCalculator.percentage(10000, {'a': 5000, 'b': null});
      expect(sum(a), 5000);
    });
  });

  group('splitItem (T08)', () {
    const soup = ReceiptItem(id: 'i', name: 'Soup', amountCents: 45000);

    test('partial item split between several people adds up', () {
      final item = SplitCalculator.splitItem(
        soup,
        method: SplitMethod.exact,
        personIds: ['a', 'b'],
        shares: {'a': 20000, 'b': 25000},
      );
      expect(item.isFullyAssigned, isTrue);
      expect(item.splitMethod, SplitMethod.exact);
    });

    test('recalculate after the amount changes keeps people and method', () {
      final split = SplitCalculator.splitItem(
        soup,
        method: SplitMethod.equal,
        personIds: ['a', 'b'],
      );
      final changed = SplitCalculator.recalculate(
        split.copyWith(amountCents: 50001),
      );
      expect(changed.assignments.map((a) => a.allocatedCents), [25001, 25000]);
    });
  });

  test('equal and 100% splits always add up exactly (random amounts)', () {
    final random = Random(51);
    for (var run = 0; run < 2000; run++) {
      final amount = random.nextInt(10000000);
      final people = List.generate(1 + random.nextInt(8), (i) => 'p$i');
      expect(sum(SplitCalculator.equal(amount, people)), amount);

      // Random percentages that add up to 100%.
      final cuts = List.generate(
        people.length - 1,
        (_) => random.nextInt(10001),
      )..sort();
      final bounds = [0, ...cuts, fullPercent];
      final percents = {
        for (var i = 0; i < people.length; i++)
          people[i]: bounds[i + 1] - bounds[i],
      };
      expect(sum(SplitCalculator.percentage(amount, percents)), amount);
    }
  });
}
