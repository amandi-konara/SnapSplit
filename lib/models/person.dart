import 'package:flutter/foundation.dart' show immutable;

/// Someone the user splits receipts with (saved under "My People").
@immutable
class Person {
  const Person({required this.id, required this.name, this.emoji});

  final String id;
  final String name;

  /// Optional emoji avatar. When null, the app shows a pastel circle with
  /// the first letter of [name].
  final String? emoji;

  /// Emoji offered in the avatar picker.
  static const pickerEmoji = [
    '😀',
    '🙂',
    '😎',
    '🤓',
    '😇',
    '🥳',
    '🤠',
    '👩',
    '👨',
    '👵',
    '👴',
    '🐶',
    '🐱',
    '🦊',
  ];

  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  Person copyWith({String? name, String? emoji}) =>
      Person(id: id, name: name ?? this.name, emoji: emoji ?? this.emoji);

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String?,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'emoji': emoji};

  @override
  bool operator ==(Object other) =>
      other is Person &&
      other.id == id &&
      other.name == name &&
      other.emoji == emoji;

  @override
  int get hashCode => Object.hash(id, name, emoji);

  @override
  String toString() => 'Person($id, $name)';
}
