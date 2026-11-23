import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'money.dart';
import 'receipt_item.dart';

/// A scanned (or typed) receipt with its items and who pays what.
@immutable
class Receipt {
  const Receipt({
    required this.id,
    required this.storeName,
    required this.date,
    this.printedTotalCents,
    this.imagePath,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String storeName;

  /// Purchase date (date only; the time part is ignored).
  final DateTime date;

  /// The total printed on the receipt, if OCR found one or the user typed it.
  /// Used to warn when the items don't add up to it.
  final Cents? printedTotalCents;

  /// Local path of the receipt photo on this phone (not uploaded).
  final String? imagePath;

  final List<ReceiptItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Sum of all item amounts. This is the receipt's total in the app.
  Cents get totalCents => items.fold(0, (sum, i) => sum + i.amountCents);

  /// Difference between the printed total and the items (0 = reconciled).
  Cents? get printedTotalDifference =>
      printedTotalCents == null ? null : printedTotalCents! - totalCents;

  /// Distinct people on this receipt, in first-seen order.
  List<String> get personIds {
    final seen = <String>{};
    return [
      for (final item in items)
        for (final a in item.assignments)
          if (seen.add(a.personId)) a.personId,
    ];
  }

  /// Total each person pays, keyed by person id.
  Map<String, Cents> get totalsByPerson {
    final totals = <String, Cents>{};
    for (final item in items) {
      for (final a in item.assignments) {
        totals.update(
          a.personId,
          (v) => v + a.allocatedCents,
          ifAbsent: () => a.allocatedCents,
        );
      }
    }
    return totals;
  }

  /// Total spent per category, keyed by category id.
  Map<String, Cents> get totalsByCategory {
    final totals = <String, Cents>{};
    for (final item in items) {
      totals.update(
        item.categoryId,
        (v) => v + item.amountCents,
        ifAbsent: () => item.amountCents,
      );
    }
    return totals;
  }

  bool get isFullyAssigned =>
      items.isNotEmpty && items.every((i) => i.isFullyAssigned);

  Receipt copyWith({
    String? storeName,
    DateTime? date,
    Cents? printedTotalCents,
    String? imagePath,
    List<ReceiptItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Receipt(
    id: id,
    storeName: storeName ?? this.storeName,
    date: date ?? this.date,
    printedTotalCents: printedTotalCents ?? this.printedTotalCents,
    imagePath: imagePath ?? this.imagePath,
    items: items ?? this.items,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'] as String,
    storeName: json['store_name'] as String,
    date: DateTime.parse(json['receipt_date'] as String),
    printedTotalCents: (json['printed_total_cents'] as num?)?.toInt(),
    imagePath: json['image_path'] as String?,
    items: [
      for (final i in (json['items'] as List?) ?? const [])
        ReceiptItem.fromJson(Map<String, dynamic>.from(i as Map)),
    ],
    createdAt: _parseDate(json['created_at']),
    updatedAt: _parseDate(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_name': storeName,
    'receipt_date': _dateOnly(date),
    'printed_total_cents': printedTotalCents,
    'image_path': imagePath,
    'items': [for (final i in items) i.toJson()],
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  static DateTime? _parseDate(Object? v) =>
      v == null ? null : DateTime.parse(v as String);

  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is Receipt &&
      other.id == id &&
      other.storeName == storeName &&
      other.date == date &&
      other.printedTotalCents == printedTotalCents &&
      other.imagePath == imagePath &&
      listEquals(other.items, items) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    storeName,
    date,
    printedTotalCents,
    imagePath,
    Object.hashAll(items),
    createdAt,
    updatedAt,
  );

  @override
  String toString() => 'Receipt($storeName, ${items.length} items)';
}
