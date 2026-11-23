import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'assignment.dart';
import 'category.dart';
import 'money.dart';
import 'split_method.dart';

/// One line on a receipt, e.g. "Rice  Rs. 500".
@immutable
class ReceiptItem {
  const ReceiptItem({
    required this.id,
    required this.name,
    required this.amountCents,
    this.categoryId = Category.otherId,
    this.splitMethod = SplitMethod.equal,
    this.assignments = const [],
  });

  final String id;
  final String name;
  final Cents amountCents;
  final String categoryId;
  final SplitMethod splitMethod;

  /// Who pays for this item, in order (leftover cents go to the first one).
  final List<Assignment> assignments;

  Cents get assignedCents =>
      assignments.fold(0, (sum, a) => sum + a.allocatedCents);

  /// Positive when part of the item has not been given to anyone yet.
  Cents get unassignedCents => amountCents - assignedCents;

  bool get isFullyAssigned => assignments.isNotEmpty && unassignedCents == 0;

  ReceiptItem copyWith({
    String? name,
    Cents? amountCents,
    String? categoryId,
    SplitMethod? splitMethod,
    List<Assignment>? assignments,
  }) => ReceiptItem(
    id: id,
    name: name ?? this.name,
    amountCents: amountCents ?? this.amountCents,
    categoryId: categoryId ?? this.categoryId,
    splitMethod: splitMethod ?? this.splitMethod,
    assignments: assignments ?? this.assignments,
  );

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
    id: json['id'] as String,
    name: json['name'] as String,
    amountCents: (json['amount_cents'] as num).toInt(),
    categoryId: (json['category_id'] as String?) ?? Category.otherId,
    splitMethod: SplitMethod.fromDb(
      (json['split_method'] as String?) ?? 'equal',
    ),
    assignments: [
      for (final a in (json['assignments'] as List?) ?? const [])
        Assignment.fromJson(Map<String, dynamic>.from(a as Map)),
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount_cents': amountCents,
    'category_id': categoryId,
    'split_method': splitMethod.dbValue,
    'assignments': [for (final a in assignments) a.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is ReceiptItem &&
      other.id == id &&
      other.name == name &&
      other.amountCents == amountCents &&
      other.categoryId == categoryId &&
      other.splitMethod == splitMethod &&
      listEquals(other.assignments, assignments);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    amountCents,
    categoryId,
    splitMethod,
    Object.hashAll(assignments),
  );

  @override
  String toString() => 'ReceiptItem($name, $amountCents)';
}
