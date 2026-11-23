import 'package:flutter/foundation.dart' show immutable;

import 'money.dart';

/// One person's part of one item.
@immutable
class Assignment {
  const Assignment({
    required this.personId,
    required this.allocatedCents,
    this.share,
  });

  final String personId;

  /// What the user typed: cents for an exact split, basis points for a
  /// percentage split, null for an equal split.
  final int? share;

  /// The amount this person pays for the item. The allocations of one item
  /// always add up to the item's amount.
  final Cents allocatedCents;

  Assignment copyWith({int? share, Cents? allocatedCents}) => Assignment(
    personId: personId,
    share: share ?? this.share,
    allocatedCents: allocatedCents ?? this.allocatedCents,
  );

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
    personId: json['person_id'] as String,
    share: (json['share'] as num?)?.toInt(),
    allocatedCents: (json['allocated_cents'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'person_id': personId,
    'share': share,
    'allocated_cents': allocatedCents,
  };

  @override
  bool operator ==(Object other) =>
      other is Assignment &&
      other.personId == personId &&
      other.share == share &&
      other.allocatedCents == allocatedCents;

  @override
  int get hashCode => Object.hash(personId, share, allocatedCents);

  @override
  String toString() => 'Assignment($personId, $allocatedCents)';
}
