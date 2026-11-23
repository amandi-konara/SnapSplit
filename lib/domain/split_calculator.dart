import '../models/models.dart';

/// Works out who pays what for one item. Pure Dart, no Flutter, so it is
/// easy to test (proposal NFR-03 and tests T06–T08).
///
/// Rules (proposal Appendix B):
/// - one person on an item pays the whole amount;
/// - a shared item is divided by the chosen method;
/// - the shares of an item add up exactly to the item amount, with leftover
///   cents going to the first person, in order.
abstract final class SplitCalculator {
  /// Everyone pays the same. Rs. 100 between 3 people -> 33.34, 33.33, 33.33.
  static List<Assignment> equal(Cents amount, List<String> personIds) {
    if (personIds.isEmpty) return const [];
    final each = amount ~/ personIds.length;
    final leftover = amount - each * personIds.length;
    return [
      for (var i = 0; i < personIds.length; i++)
        Assignment(
          personId: personIds[i],
          allocatedCents: each + (i == 0 ? leftover : 0),
        ),
    ];
  }

  /// Each person pays the amount typed for them (null = not typed yet = 0).
  /// The result may not add up to the item amount; check with
  /// [ReceiptItem.unassignedCents].
  static List<Assignment> exact(Map<String, Cents?> amounts) => [
    for (final entry in amounts.entries)
      Assignment(
        personId: entry.key,
        share: entry.value,
        allocatedCents: entry.value ?? 0,
      ),
  ];

  /// Each person pays a percentage (in basis points, 100% = 10000).
  ///
  /// Amounts are rounded down; when the percentages add up to exactly 100%
  /// the leftover cents go to the first person, so the item is fully
  /// covered. Otherwise the gap shows up as unassigned.
  static List<Assignment> percentage(
    Cents amount,
    Map<String, BasisPoints?> percents,
  ) {
    final entries = percents.entries.toList();
    final result = [
      for (final e in entries)
        Assignment(
          personId: e.key,
          share: e.value,
          allocatedCents: amount * (e.value ?? 0) ~/ fullPercent,
        ),
    ];
    final totalPercent = entries.fold<int>(0, (s, e) => s + (e.value ?? 0));
    if (totalPercent == fullPercent && result.isNotEmpty) {
      final allocated = result.fold<int>(0, (s, a) => s + a.allocatedCents);
      final first = result.first;
      result[0] = first.copyWith(
        allocatedCents: first.allocatedCents + (amount - allocated),
      );
    }
    return result;
  }

  /// Re-splits [item] between [personIds] with [method].
  ///
  /// [shares] holds what the user typed per person (cents for exact, basis
  /// points for percentage); it is ignored for an equal split. People not in
  /// [shares] start at null (nothing typed).
  static ReceiptItem splitItem(
    ReceiptItem item, {
    required SplitMethod method,
    required List<String> personIds,
    Map<String, int?> shares = const {},
  }) {
    final typed = {for (final id in personIds) id: shares[id]};
    final assignments = switch (method) {
      SplitMethod.equal => equal(item.amountCents, personIds),
      SplitMethod.exact => exact(typed),
      SplitMethod.percentage => percentage(item.amountCents, typed),
    };
    return item.copyWith(splitMethod: method, assignments: assignments);
  }

  /// Recalculates an item after its amount changed, keeping the people,
  /// method and typed shares.
  static ReceiptItem recalculate(ReceiptItem item) => splitItem(
    item,
    method: item.splitMethod,
    personIds: [for (final a in item.assignments) a.personId],
    shares: {for (final a in item.assignments) a.personId: a.share},
  );
}
