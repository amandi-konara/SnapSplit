import 'package:flutter/foundation.dart' show immutable;

/// What kind of thing an item is (Groceries, Medicine...). Kept separate from
/// *who* pays for it (see [Assignment]).
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    this.isBuiltIn = false,
  });

  final String id;
  final String name;
  final String emoji;

  /// Built-in categories are shown with a lock and cannot be deleted.
  final bool isBuiltIn;

  static const otherId = 'other';

  /// The built-in list, in the order shown in the app.
  static const builtIn = <Category>[
    Category(id: 'groceries', name: 'Groceries', emoji: '🛒', isBuiltIn: true),
    Category(id: 'food', name: 'Food', emoji: '🍔', isBuiltIn: true),
    Category(id: 'household', name: 'Household', emoji: '🏠', isBuiltIn: true),
    Category(
      id: 'personal_care',
      name: 'Personal Care',
      emoji: '💄',
      isBuiltIn: true,
    ),
    Category(id: 'medicine', name: 'Medicine', emoji: '💊', isBuiltIn: true),
    Category(id: 'snacks', name: 'Snacks', emoji: '🍫', isBuiltIn: true),
    Category(id: 'transport', name: 'Transport', emoji: '🚌', isBuiltIn: true),
    Category(id: 'drinks', name: 'Drinks', emoji: '🥤', isBuiltIn: true),
    Category(id: 'clothing', name: 'Clothing', emoji: '👕', isBuiltIn: true),
    Category(
      id: 'electronics',
      name: 'Electronics',
      emoji: '🔌',
      isBuiltIn: true,
    ),
    Category(id: otherId, name: 'Other', emoji: '📦', isBuiltIn: true),
  ];

  /// Emoji offered when the user creates their own category.
  static const pickerEmoji = [
    '📦',
    '🛒',
    '🍔',
    '🏠',
    '💄',
    '💊',
    '🍫',
    '🚌',
    '🥤',
    '👕',
    '🔌',
    '🎁',
    '📚',
    '🐾',
    '🎮',
    '✈️',
    '⛽',
    '🎉',
  ];

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: (json['emoji'] as String?) ?? '📦',
    isBuiltIn: (json['is_built_in'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'is_built_in': isBuiltIn,
  };

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.emoji == emoji &&
      other.isBuiltIn == isBuiltIn;

  @override
  int get hashCode => Object.hash(id, name, emoji, isBuiltIn);

  @override
  String toString() => 'Category($id, $name)';
}
