import 'package:flutter/foundation.dart' show immutable, listEquals, setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers.dart';
import '../../domain/category_suggester.dart';
import '../../domain/receipt_parser.dart';
import '../../domain/split_calculator.dart';
import '../../models/models.dart';

const _uuid = Uuid();

/// The receipt being scanned/edited, carried through
/// Review -> Categories -> People -> Assign -> Summary.
@immutable
class DraftReceipt {
  const DraftReceipt({
    required this.receipt,
    this.personIds = const [],
    this.manualCategoryItemIds = const {},
    this.isEditing = false,
  });

  final Receipt receipt;

  /// People picked on the "Who's sharing this?" step, in the order picked.
  final List<String> personIds;

  /// Items whose category the user chose by hand (no more suggestions).
  final Set<String> manualCategoryItemIds;

  /// True when changing a receipt that was already saved (FR-13).
  final bool isEditing;

  List<ReceiptItem> get items => receipt.items;

  /// Review can continue when there is a store name and every item has a
  /// name and an amount above zero.
  bool get isReviewComplete =>
      receipt.storeName.trim().isNotEmpty &&
      items.isNotEmpty &&
      items.every((i) => i.name.trim().isNotEmpty && i.amountCents > 0);

  /// Total not yet given to anyone, over all items.
  Cents get unassignedCents =>
      items.fold(0, (sum, i) => sum + i.unassignedCents);

  /// Every item is split between at least one person and adds up exactly.
  bool get isFullyAssigned => receipt.isFullyAssigned;

  DraftReceipt copyWith({
    Receipt? receipt,
    List<String>? personIds,
    Set<String>? manualCategoryItemIds,
  }) => DraftReceipt(
    receipt: receipt ?? this.receipt,
    personIds: personIds ?? this.personIds,
    manualCategoryItemIds: manualCategoryItemIds ?? this.manualCategoryItemIds,
    isEditing: isEditing,
  );

  @override
  bool operator ==(Object other) =>
      other is DraftReceipt &&
      other.receipt == receipt &&
      listEquals(other.personIds, personIds) &&
      setEquals(other.manualCategoryItemIds, manualCategoryItemIds) &&
      other.isEditing == isEditing;

  @override
  int get hashCode => Object.hash(
    receipt,
    Object.hashAll(personIds),
    Object.hashAllUnordered(manualCategoryItemIds),
    isEditing,
  );
}

/// `ref.watch(draftReceiptProvider)` is null when no receipt is in progress.
final draftReceiptProvider =
    NotifierProvider<DraftReceiptController, DraftReceipt?>(
      DraftReceiptController.new,
    );

class DraftReceiptController extends Notifier<DraftReceipt?> {
  @override
  DraftReceipt? build() => null;

  DraftReceipt get _draft {
    final draft = state;
    if (draft == null) throw StateError('No receipt in progress.');
    return draft;
  }

  void _setReceipt(Receipt receipt) =>
      state = _draft.copyWith(receipt: receipt);

  void _setItems(List<ReceiptItem> items) =>
      _setReceipt(_draft.receipt.copyWith(items: items));

  void _updateItem(String itemId, ReceiptItem Function(ReceiptItem) change) =>
      _setItems([
        for (final item in _draft.items)
          item.id == itemId ? change(item) : item,
      ]);

  // --- Starting and finishing -----------------------------------------

  /// Starts a new receipt from what OCR read (or empty, for typing it in).
  void startNew({ParsedReceipt? parsed, String? imagePath}) {
    final now = DateTime.now();
    state = DraftReceipt(
      receipt: Receipt(
        id: _uuid.v4(),
        storeName: parsed?.storeName ?? '',
        date: parsed?.date ?? DateTime(now.year, now.month, now.day),
        printedTotalCents: parsed?.totalCents,
        imagePath: imagePath,
        items: [
          for (final p in parsed?.items ?? const <ParsedItem>[])
            ReceiptItem(
              id: _uuid.v4(),
              name: p.name,
              amountCents: p.amountCents,
              categoryId: CategorySuggester.suggest(p.name),
            ),
        ],
      ),
    );
  }

  /// Loads a saved receipt to change it and save it again (FR-13).
  void startEditing(Receipt saved) {
    state = DraftReceipt(
      receipt: saved,
      personIds: saved.personIds,
      manualCategoryItemIds: {for (final i in saved.items) i.id},
      isEditing: true,
    );
  }

  /// Saves the receipt and clears the draft. Throws [DataException] with a
  /// message for the user if saving fails.
  Future<Receipt> save() async {
    final saved = await ref
        .read(receiptRepositoryProvider)
        .save(_draft.receipt);
    state = null;
    return saved;
  }

  void discard() => state = null;

  // --- Review ---------------------------------------------------------

  void setStoreName(String name) =>
      _setReceipt(_draft.receipt.copyWith(storeName: name));

  void setDate(DateTime date) => _setReceipt(
    _draft.receipt.copyWith(date: DateTime(date.year, date.month, date.day)),
  );

  /// Returns the new item's id.
  String addItem() {
    final item = ReceiptItem(id: _uuid.v4(), name: '', amountCents: 0);
    _setItems([..._draft.items, item]);
    return item.id;
  }

  void removeItem(String itemId) => _setItems([
    for (final i in _draft.items)
      if (i.id != itemId) i,
  ]);

  /// Changes an item's name and/or amount. The category suggestion follows
  /// the name until the user picks one by hand; any split is recalculated.
  void editItem(String itemId, {String? name, Cents? amountCents}) {
    final manual = _draft.manualCategoryItemIds.contains(itemId);
    _updateItem(itemId, (item) {
      var changed = item.copyWith(name: name, amountCents: amountCents);
      if (name != null && !manual) {
        changed = changed.copyWith(categoryId: CategorySuggester.suggest(name));
      }
      if (amountCents != null && changed.assignments.isNotEmpty) {
        changed = SplitCalculator.recalculate(changed);
      }
      return changed;
    });
  }

  // --- Categories -----------------------------------------------------

  void setCategory(String itemId, String categoryId) {
    _updateItem(itemId, (item) => item.copyWith(categoryId: categoryId));
    state = _draft.copyWith(
      manualCategoryItemIds: {..._draft.manualCategoryItemIds, itemId},
    );
  }

  // --- People ---------------------------------------------------------

  /// Adds or removes a person from this receipt. Removing them also takes
  /// them off every item.
  void togglePerson(String personId) {
    final ids = _draft.personIds;
    if (!ids.contains(personId)) {
      state = _draft.copyWith(personIds: [...ids, personId]);
      return;
    }
    state = _draft.copyWith(
      personIds: [
        for (final id in ids)
          if (id != personId) id,
      ],
    );
    _setItems([
      for (final item in _draft.items)
        item.assignments.any((a) => a.personId == personId)
            ? _withoutPerson(item, personId)
            : item,
    ]);
  }

  /// Called when leaving the People step: items nobody is on yet are split
  /// equally between everyone picked.
  void prepareAssignments() {
    final people = _draft.personIds;
    _setItems([
      for (final item in _draft.items)
        item.assignments.isEmpty
            ? SplitCalculator.splitItem(
                item,
                method: SplitMethod.equal,
                personIds: people,
              )
            : item,
    ]);
  }

  // --- Assign ---------------------------------------------------------

  /// Switches Equal / Exact / Percent for an item. Typed shares are cleared
  /// because cents and percentages don't convert.
  void setSplitMethod(String itemId, SplitMethod method) => _updateItem(
    itemId,
    (item) => SplitCalculator.splitItem(
      item,
      method: method,
      personIds: [for (final a in item.assignments) a.personId],
    ),
  );

  /// Ticks or unticks a person on one item.
  void toggleItemPerson(String itemId, String personId) => _updateItem(
    itemId,
    (item) => item.assignments.any((a) => a.personId == personId)
        ? _withoutPerson(item, personId)
        : SplitCalculator.splitItem(
            item,
            method: item.splitMethod,
            // Keep the receipt's people order so leftovers are predictable.
            personIds: [
              for (final id in _draft.personIds)
                if (id == personId ||
                    item.assignments.any((a) => a.personId == id))
                  id,
            ],
            shares: {for (final a in item.assignments) a.personId: a.share},
          ),
  );

  /// Sets what was typed for a person on an exact (cents) or percentage
  /// (basis points) split. Null clears it.
  void setShare(String itemId, String personId, int? share) => _updateItem(
    itemId,
    (item) => SplitCalculator.splitItem(
      item,
      method: item.splitMethod,
      personIds: [for (final a in item.assignments) a.personId],
      shares: {
        for (final a in item.assignments)
          a.personId: a.personId == personId ? share : a.share,
      },
    ),
  );

  static ReceiptItem _withoutPerson(ReceiptItem item, String personId) =>
      SplitCalculator.splitItem(
        item,
        method: item.splitMethod,
        personIds: [
          for (final a in item.assignments)
            if (a.personId != personId) a.personId,
        ],
        shares: {for (final a in item.assignments) a.personId: a.share},
      );
}
