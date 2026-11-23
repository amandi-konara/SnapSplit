import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/data/fake/fake_repositories.dart';
import 'package:snapsplit/data/providers.dart';
import 'package:snapsplit/domain/receipt_parser.dart';
import 'package:snapsplit/features/split/draft_receipt.dart';
import 'package:snapsplit/models/models.dart';

void main() {
  late ProviderContainer container;
  late InMemoryReceiptRepository receipts;

  DraftReceiptController ctrl() =>
      container.read(draftReceiptProvider.notifier);
  DraftReceipt draft() => container.read(draftReceiptProvider)!;
  ReceiptItem item(int i) => draft().items[i];

  setUp(() {
    receipts = InMemoryReceiptRepository();
    container = ProviderContainer(
      overrides: [receiptRepositoryProvider.overrideWithValue(receipts)],
    );
  });
  tearDown(() => container.dispose());

  test('starts from OCR results with suggested categories', () {
    ctrl().startNew(
      parsed: const ParsedReceipt(
        storeName: 'Keells',
        totalCents: 75000,
        items: [ParsedItem('Panadol', 25000), ParsedItem('Rice', 50000)],
      ),
    );
    expect(draft().receipt.storeName, 'Keells');
    expect(draft().receipt.printedTotalCents, 75000);
    expect(draft().items.map((i) => i.categoryId), ['medicine', 'groceries']);
    expect(draft().isReviewComplete, isTrue);
  });

  test('review needs a store and named, priced items (T03, T04)', () {
    ctrl().startNew();
    expect(draft().isReviewComplete, isFalse);
    ctrl().setStoreName('Pure Foods');
    final id = ctrl().addItem();
    expect(draft().isReviewComplete, isFalse);
    ctrl().editItem(id, name: 'Soup', amountCents: 45000);
    expect(draft().isReviewComplete, isTrue);
    expect(item(0).categoryId, 'food');
    ctrl().removeItem(id);
    expect(draft().items, isEmpty);
  });

  test('suggestions stop once the user picks a category', () {
    ctrl().startNew();
    final id = ctrl().addItem();
    ctrl().setCategory(id, 'snacks');
    ctrl().editItem(id, name: 'Rice');
    expect(item(0).categoryId, 'snacks');
  });

  test('people step splits unassigned items equally (T06)', () {
    ctrl().startNew(
      parsed: const ParsedReceipt(items: [ParsedItem('Soup', 45000)]),
    );
    ctrl()
      ..togglePerson('anuru')
      ..togglePerson('kamal')
      ..prepareAssignments();
    expect(item(0).assignments.map((a) => a.allocatedCents), [22500, 22500]);
    expect(draft().isFullyAssigned, isTrue);
  });

  test('exact and percent shares update the split (T07, T08)', () {
    ctrl().startNew(
      parsed: const ParsedReceipt(items: [ParsedItem('Soup', 45000)]),
    );
    ctrl()
      ..togglePerson('a')
      ..togglePerson('b')
      ..prepareAssignments();
    final id = item(0).id;

    ctrl().setSplitMethod(id, SplitMethod.exact);
    expect(draft().unassignedCents, 45000);
    ctrl().setShare(id, 'a', 30000);
    ctrl().setShare(id, 'b', 15000);
    expect(draft().isFullyAssigned, isTrue);

    ctrl().setSplitMethod(id, SplitMethod.percentage);
    ctrl().setShare(id, 'a', 4000);
    ctrl().setShare(id, 'b', 6000);
    expect(item(0).assignments.map((a) => a.allocatedCents), [18000, 27000]);
  });

  test('unticking a person re-splits the item; removing them clears them', () {
    ctrl().startNew(
      parsed: const ParsedReceipt(items: [ParsedItem('Soup', 45000)]),
    );
    ctrl()
      ..togglePerson('a')
      ..togglePerson('b')
      ..prepareAssignments();
    final id = item(0).id;
    ctrl().toggleItemPerson(id, 'b');
    expect(item(0).assignments.single.allocatedCents, 45000);
    ctrl().toggleItemPerson(id, 'b');
    expect(item(0).assignments.length, 2);

    ctrl().togglePerson('a');
    expect(draft().personIds, ['b']);
    expect(item(0).assignments.single.personId, 'b');
  });

  test('changing an amount after splitting recalculates', () {
    ctrl().startNew(
      parsed: const ParsedReceipt(items: [ParsedItem('Soup', 45000)]),
    );
    ctrl()
      ..togglePerson('a')
      ..togglePerson('b')
      ..prepareAssignments();
    ctrl().editItem(item(0).id, amountCents: 50000);
    expect(item(0).assignments.map((a) => a.allocatedCents), [25000, 25000]);
  });

  test('save stores the receipt and clears the draft', () async {
    ctrl().startNew(
      parsed: const ParsedReceipt(
        storeName: 'Pure Foods',
        items: [ParsedItem('Soup', 45000)],
      ),
    );
    ctrl()
      ..togglePerson('a')
      ..prepareAssignments();
    final saved = await ctrl().save();
    expect(container.read(draftReceiptProvider), isNull);
    expect((await receipts.getById(saved.id))?.storeName, 'Pure Foods');
  });

  test('editing a saved receipt keeps its people and categories', () {
    final saved = Receipt(
      id: 'r',
      storeName: 'Keells',
      date: DateTime(2026, 11, 1),
      items: const [
        ReceiptItem(
          id: 'i',
          name: 'Rice',
          amountCents: 1000,
          categoryId: 'snacks',
          assignments: [Assignment(personId: 'a', allocatedCents: 1000)],
        ),
      ],
    );
    ctrl().startEditing(saved);
    expect(draft().isEditing, isTrue);
    expect(draft().personIds, ['a']);
    ctrl().editItem('i', name: 'Rice 5kg');
    expect(item(0).categoryId, 'snacks');
  });
}
