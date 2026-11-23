import 'package:flutter/foundation.dart' show immutable;

/// The signed-in account.
@immutable
class AppUser {
  const AppUser({required this.id, required this.email, this.displayName});

  final String id;
  final String email;
  final String? displayName;

  /// Name for greetings: the display name, else the part of the email
  /// before "@", capitalised.
  String get firstName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    final local = email.split('@').first;
    if (local.isEmpty) return 'there';
    return local[0].toUpperCase() + local.substring(1);
  }

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(id, email, displayName);
}
