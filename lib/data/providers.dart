import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'fake/fake_repositories.dart';
import 'fake/sample_data.dart';
import 'repositories.dart';

// ---------------------------------------------------------------------------
// Repositories.
//
// These return the fake in-memory versions for now. Track B swaps each one
// for its Supabase version here (one line per repository) in week 2; screens
// don't change. Tests can override them with `ProviderScope(overrides: ...)`.
// ---------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(),
);

final receiptRepositoryProvider = Provider<ReceiptRepository>(
  (ref) => InMemoryReceiptRepository(seed: SampleData.receipts()),
);

final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => InMemoryPeopleRepository(
    seed: SampleData.people,
    receipts: ref.watch(receiptRepositoryProvider),
  ),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => InMemoryCategoryRepository(),
);

// ---------------------------------------------------------------------------
// Live data for screens: `ref.watch(receiptsProvider)` gives an AsyncValue.
// ---------------------------------------------------------------------------

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final receiptsProvider = StreamProvider<List<Receipt>>(
  (ref) => ref.watch(receiptRepositoryProvider).watchAll(),
);

final peopleProvider = StreamProvider<List<Person>>(
  (ref) => ref.watch(peopleRepositoryProvider).watchAll(),
);

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// One receipt by id, kept up to date (null if it was deleted).
final receiptByIdProvider = Provider.family<AsyncValue<Receipt?>, String>(
  (ref, id) => ref
      .watch(receiptsProvider)
      .whenData((list) => list.where((r) => r.id == id).firstOrNull),
);
