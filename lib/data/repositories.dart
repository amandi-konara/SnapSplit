/// Data contracts. Screens only talk to these interfaces, so they work the
/// same with the fake in-memory versions (now) and the Supabase versions
/// (Track B, week 2).
library;

import '../models/models.dart';

/// Thrown by repositories with a message that can be shown to the user.
class DataException implements Exception {
  const DataException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  /// Emits the signed-in user, or null after sign-out. Emits the current
  /// value first.
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({required String email, required String password});
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

abstract interface class ReceiptRepository {
  /// All of the user's receipts, newest first. Emits again after every change.
  Stream<List<Receipt>> watchAll();

  Future<Receipt?> getById(String id);

  /// Creates or replaces the receipt with its items and assignments in one go.
  Future<Receipt> save(Receipt receipt);

  Future<void> delete(String id);
}

abstract interface class PeopleRepository {
  /// The user's saved people, sorted by name.
  Stream<List<Person>> watchAll();

  /// Throws [DataException] if a person with the same name already exists.
  Future<Person> add(String name, {String? emoji});

  Future<Person> update(Person person);

  /// Throws [DataException] if the person is on a saved receipt.
  Future<void> delete(String id);
}

abstract interface class CategoryRepository {
  /// Built-in categories first, then the user's own.
  Stream<List<Category>> watchAll();

  Future<Category> addCustom(String name, String emoji);

  /// Built-in categories can't be deleted.
  Future<void> deleteCustom(String id);
}
