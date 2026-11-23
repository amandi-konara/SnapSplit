import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../models/models.dart';
import '../repositories.dart';
import 'sample_data.dart';

const _uuid = Uuid();

/// A small helper: keeps a value and replays it to every new listener.
class _Store<T> {
  _Store(this._value);
  T _value;
  final _controller = StreamController<T>.broadcast();

  T get value => _value;
  set value(T v) {
    _value = v;
    _controller.add(v);
  }

  Stream<T> watch() async* {
    yield _value;
    yield* _controller.stream;
  }
}

/// Fake sign-in for building screens before Supabase is ready.
/// Any email works; the password must be at least 6 characters.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({bool signedIn = true})
    : _user = _Store(signedIn ? SampleData.user : null);

  final _Store<AppUser?> _user;

  @override
  Stream<AppUser?> authStateChanges() => _user.watch();

  @override
  AppUser? get currentUser => _user.value;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await _delay();
    if (password.length < 6) {
      throw const DataException('Wrong email or password.');
    }
    final user = AppUser(id: SampleData.user.id, email: email.trim());
    _user.value = user;
    return user;
  }

  @override
  Future<AppUser> signUp({required String email, required String password}) =>
      signIn(email: email, password: password);

  @override
  Future<void> sendPasswordReset(String email) => _delay();

  @override
  Future<void> signOut() async {
    await _delay();
    _user.value = null;
  }
}

class InMemoryReceiptRepository implements ReceiptRepository {
  InMemoryReceiptRepository({List<Receipt> seed = const []})
    : _receipts = _Store(_sorted(seed));

  final _Store<List<Receipt>> _receipts;

  static List<Receipt> _sorted(List<Receipt> list) => [...list]
    ..sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date);
    });

  @override
  Stream<List<Receipt>> watchAll() => _receipts.watch();

  @override
  Future<Receipt?> getById(String id) async {
    for (final r in _receipts.value) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Future<Receipt> save(Receipt receipt) async {
    await _delay();
    for (final item in receipt.items) {
      if (item.assignments.isNotEmpty && item.unassignedCents != 0) {
        throw DataException(
          '"${item.name}" is not fully split yet (${formatRs(item.unassignedCents)} left).',
        );
      }
    }
    final now = DateTime.now();
    final existing = await getById(receipt.id);
    final saved = receipt.copyWith(
      createdAt: existing?.createdAt ?? receipt.createdAt ?? now,
      updatedAt: now,
    );
    _receipts.value = _sorted([
      for (final r in _receipts.value)
        if (r.id != saved.id) r,
      saved,
    ]);
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _receipts.value = [
      for (final r in _receipts.value)
        if (r.id != id) r,
    ];
  }
}

class InMemoryPeopleRepository implements PeopleRepository {
  InMemoryPeopleRepository({
    List<Person> seed = const [],
    required this.receipts,
  }) : _people = _Store(_sorted(seed));

  final _Store<List<Person>> _people;

  /// Used to check whether a person is on a saved receipt before deleting.
  final ReceiptRepository receipts;

  static List<Person> _sorted(List<Person> list) =>
      [...list]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  @override
  Stream<List<Person>> watchAll() => _people.watch();

  void _checkName(String name, {String? exceptId}) {
    final clean = name.trim();
    if (clean.isEmpty) throw const DataException('Please enter a name.');
    if (clean.length > 40) {
      throw const DataException('Names can be up to 40 characters.');
    }
    final taken = _people.value.any(
      (p) => p.id != exceptId && p.name.toLowerCase() == clean.toLowerCase(),
    );
    if (taken) throw DataException('$clean is already in your people.');
  }

  @override
  Future<Person> add(String name, {String? emoji}) async {
    _checkName(name);
    final person = Person(id: _uuid.v4(), name: name.trim(), emoji: emoji);
    _people.value = _sorted([..._people.value, person]);
    return person;
  }

  @override
  Future<Person> update(Person person) async {
    _checkName(person.name, exceptId: person.id);
    final clean = person.copyWith(name: person.name.trim());
    _people.value = _sorted([
      for (final p in _people.value) p.id == person.id ? clean : p,
    ]);
    return clean;
  }

  @override
  Future<void> delete(String id) async {
    final saved = await receipts.watchAll().first;
    final used = saved.any((r) => r.personIds.contains(id));
    if (used) {
      throw const DataException(
        'This person is on a saved receipt, so they can\'t be removed.',
      );
    }
    _people.value = [
      for (final p in _people.value)
        if (p.id != id) p,
    ];
  }
}

class InMemoryCategoryRepository implements CategoryRepository {
  InMemoryCategoryRepository({List<Category> custom = const []})
    : _custom = _Store(custom);

  final _Store<List<Category>> _custom;

  @override
  Stream<List<Category>> watchAll() =>
      _custom.watch().map((custom) => [...Category.builtIn, ...custom]);

  @override
  Future<Category> addCustom(String name, String emoji) async {
    final clean = name.trim();
    if (clean.isEmpty) throw const DataException('Please enter a name.');
    final all = [...Category.builtIn, ..._custom.value];
    if (all.any((c) => c.name.toLowerCase() == clean.toLowerCase())) {
      throw DataException('$clean already exists.');
    }
    final category = Category(id: _uuid.v4(), name: clean, emoji: emoji);
    _custom.value = [..._custom.value, category];
    return category;
  }

  @override
  Future<void> deleteCustom(String id) async {
    if (Category.builtIn.any((c) => c.id == id)) {
      throw const DataException('Built-in categories can\'t be deleted.');
    }
    _custom.value = [
      for (final c in _custom.value)
        if (c.id != id) c,
    ];
  }
}

/// A short pause so loading states are visible while using fake data.
Future<void> _delay() => Future.delayed(const Duration(milliseconds: 300));
