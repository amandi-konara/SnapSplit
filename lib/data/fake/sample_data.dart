import '../../models/models.dart';

/// Example data for the fake repositories, so every screen has something to
/// show before Supabase is connected. Receipt 1 is Appendix A of the
/// proposal; receipt 2 is the soup split from the Base44 demo.
abstract final class SampleData {
  static const user = AppUser(
    id: 'demo-user',
    email: 'demo@snapsplit.app',
    displayName: 'Amandi',
  );

  static const amandi = Person(id: 'p-amandi', name: 'Amandi', emoji: '😀');
  static const mom = Person(id: 'p-mom', name: 'Mom', emoji: '👩');
  static const anuru = Person(id: 'p-anuru', name: 'Anuru');
  static const kamal = Person(id: 'p-kamal', name: 'Kamal');

  static const people = [amandi, mom, anuru, kamal];

  static List<Receipt> receipts() {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    return [
      Receipt(
        id: 'r-pure-foods',
        storeName: 'Pure Foods',
        date: day,
        printedTotalCents: 45000,
        createdAt: day,
        items: const [
          ReceiptItem(
            id: 'i-soup',
            name: 'Soup',
            amountCents: 45000,
            categoryId: 'food',
            assignments: [
              Assignment(personId: 'p-anuru', allocatedCents: 22500),
              Assignment(personId: 'p-kamal', allocatedCents: 22500),
            ],
          ),
        ],
      ),
      Receipt(
        id: 'r-keells',
        storeName: 'Keells',
        date: day.subtract(const Duration(days: 3)),
        printedTotalCents: 260000,
        createdAt: day.subtract(const Duration(days: 3)),
        items: const [
          // "Family" items are shared equally by Amandi and Mom.
          ReceiptItem(
            id: 'i-rice',
            name: 'Rice',
            amountCents: 50000,
            categoryId: 'groceries',
            assignments: [
              Assignment(personId: 'p-amandi', allocatedCents: 25000),
              Assignment(personId: 'p-mom', allocatedCents: 25000),
            ],
          ),
          ReceiptItem(
            id: 'i-shampoo',
            name: 'Shampoo',
            amountCents: 85000,
            categoryId: 'personal_care',
            assignments: [
              Assignment(personId: 'p-amandi', allocatedCents: 85000),
            ],
          ),
          ReceiptItem(
            id: 'i-panadol',
            name: 'Panadol',
            amountCents: 25000,
            categoryId: 'medicine',
            assignments: [Assignment(personId: 'p-mom', allocatedCents: 25000)],
          ),
          ReceiptItem(
            id: 'i-milk',
            name: 'Milk',
            amountCents: 30000,
            categoryId: 'groceries',
            assignments: [
              Assignment(personId: 'p-amandi', allocatedCents: 15000),
              Assignment(personId: 'p-mom', allocatedCents: 15000),
            ],
          ),
          ReceiptItem(
            id: 'i-detergent',
            name: 'Detergent',
            amountCents: 70000,
            categoryId: 'household',
            splitMethod: SplitMethod.percentage,
            assignments: [
              Assignment(
                personId: 'p-amandi',
                share: 4000,
                allocatedCents: 28000,
              ),
              Assignment(personId: 'p-mom', share: 6000, allocatedCents: 42000),
            ],
          ),
        ],
      ),
    ];
  }
}
