import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/models/models.dart';
import 'package:snapsplit/theme/app_theme.dart';
import 'package:snapsplit/widgets/category_badge.dart';
import 'package:snapsplit/widgets/person_avatar.dart';
import 'package:snapsplit/widgets/status_chip.dart';

void main() {
  setUpAll(() => AppTheme.useGoogleFonts = false);

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('avatar shows emoji, or the initial when there is none', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const Row(
          children: [
            PersonAvatar(
              person: Person(id: '1', name: 'kamal'),
            ),
            PersonAvatar(
              person: Person(id: '2', name: 'Mom', emoji: '👩'),
            ),
          ],
        ),
      ),
    );
    expect(find.text('K'), findsOneWidget);
    expect(find.text('👩'), findsOneWidget);
  });

  testWidgets('status chips show their message', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            StatusChip.success('All assigned!'),
            StatusChip.warning('Rs. 450 still to assign'),
          ],
        ),
      ),
    );
    expect(find.text('All assigned!'), findsOneWidget);
    expect(find.text('Rs. 450 still to assign'), findsOneWidget);
  });

  test('categoryFor falls back to Other for unknown ids', () {
    expect(categoryFor('medicine').name, 'Medicine');
    expect(categoryFor('deleted-custom').id, Category.otherId);
    const books = Category(id: 'c1', name: 'Books', emoji: '📚');
    expect(categoryFor('c1', [books]), books);
  });
}
