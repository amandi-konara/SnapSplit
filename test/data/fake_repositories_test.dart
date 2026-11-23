import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/data/fake/fake_repositories.dart';
import 'package:snapsplit/data/fake/sample_data.dart';
import 'package:snapsplit/data/repositories.dart';
import 'package:snapsplit/models/models.dart';

void main() {
  group('InMemoryReceiptRepository', () {
    test('lists newest first and emits after a save', () async {
      final repo = InMemoryReceiptRepository(seed: SampleData.receipts());
      final first = await repo.watchAll().first;
      expect(first.map((r) => r.storeName), ['Pure Foods', 'Keells']);

      final saved = await repo.save(
        Receipt(id: 'new', storeName: 'Cargills', date: DateTime(2020)),
      );
      expect(saved.createdAt, isNotNull);
      final after = await repo.watchAll().first;
      expect(after.last.storeName, 'Cargills');
    });

    test('refuses a half-split item', () async {
      final repo = InMemoryReceiptRepository();
      final receipt = Receipt(
        id: 'r',
        storeName: 'Keells',
        date: DateTime(2026, 11, 23),
        items: const [
          ReceiptItem(
            id: 'i',
            name: 'Soup',
            amountCents: 45000,
            assignments: [Assignment(personId: 'a', allocatedCents: 1000)],
          ),
        ],
      );
      expect(repo.save(receipt), throwsA(isA<DataException>()));
    });
  });

  group('InMemoryPeopleRepository', () {
    InMemoryPeopleRepository make() => InMemoryPeopleRepository(
      seed: SampleData.people,
      receipts: InMemoryReceiptRepository(seed: SampleData.receipts()),
    );

    test('names are unique, ignoring case', () async {
      final repo = make();
      expect(repo.add('kamal'), throwsA(isA<DataException>()));
      final nimal = await repo.add('  Nimal ');
      expect(nimal.name, 'Nimal');
    });

    test('a person on a saved receipt cannot be deleted', () async {
      final repo = make();
      expect(repo.delete('p-kamal'), throwsA(isA<DataException>()));
      final extra = await repo.add('Nimal');
      await repo.delete(extra.id);
      final people = await repo.watchAll().first;
      expect(people.any((p) => p.id == extra.id), isFalse);
    });
  });

  test('built-in categories cannot be deleted', () async {
    final repo = InMemoryCategoryRepository();
    expect(repo.deleteCustom('food'), throwsA(isA<DataException>()));
    await repo.addCustom('Books', '📚');
    final all = await repo.watchAll().first;
    expect(all.length, Category.builtIn.length + 1);
  });

  test('fake sign-in and sign-out', () async {
    final auth = FakeAuthRepository(signedIn: false);
    expect(auth.currentUser, isNull);
    await auth.signIn(email: 'a@b.com', password: 'secret1');
    expect(auth.currentUser?.email, 'a@b.com');
    await auth.signOut();
    expect(auth.currentUser, isNull);
  });
}
