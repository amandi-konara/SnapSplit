import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/app.dart';
import 'package:snapsplit/data/fake/fake_repositories.dart';
import 'package:snapsplit/data/providers.dart';
import 'package:snapsplit/theme/app_theme.dart';

void main() {
  setUpAll(() => AppTheme.useGoogleFonts = false);

  Future<void> pumpApp(WidgetTester tester, {bool signedIn = true}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(signedIn: signedIn),
          ),
        ],
        child: const SnapSplitApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('signed-in user lands on Home with the bottom bar', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Ready to split something?'), findsOneWidget);
    expect(find.text('Hey Amandi! 👋'), findsOneWidget);
    for (final tab in ['Home', 'History', 'Insights', 'Profile']) {
      expect(find.text(tab), findsOneWidget);
    }
  });

  testWidgets('signed-out user is sent to Login', (tester) async {
    await pumpApp(tester, signedIn: false);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('logging out from Profile shows Login', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log out'));
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('the scan flow can be clicked through to Summary', (
    tester,
  ) async {
    await pumpApp(tester);
    Future<void> tap(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await tap('Scan Receipt');
    expect(find.text('Scan a receipt 📷'), findsOneWidget);
    await tap('Type it in instead');

    // Review: Next stays disabled until there is a store and a priced item.
    expect(find.text("Let's add the items ✍️"), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Store name'),
      'Pure Foods',
    );
    await tap('Add item');
    await tester.enterText(find.widgetWithText(TextField, 'Item name'), 'Soup');
    await tester.enterText(find.widgetWithText(TextField, '0'), '450');
    await tester.pumpAndSettle();
    expect(find.text('Rs. 450'), findsOneWidget); // total pill
    await tap('Looks good! Next →');

    // Categories: "Soup" was suggested as Food.
    expect(find.text('What kind of things? 🏷️'), findsOneWidget);
    expect(find.text('🍔  Food'), findsOneWidget);
    await tap('Next →');
    // People: pick two saved people and add a new one, then untick them.
    expect(find.text("Who's sharing this? 👥"), findsOneWidget);
    await tap('Anuru');
    await tap('Kamal');
    await tester.enterText(
      find.widgetWithText(TextField, 'Add someone new…'),
      'Nimal',
    );
    await tester.tap(find.byTooltip('Add person'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with 3 →'), findsOneWidget);
    await tap('Nimal');
    await tap('Continue with 2 →');
    await tap('Continue to summary →');
    expect(find.text('All split up! 🎉'), findsOneWidget);
    await tap('Save receipt ✓');
    expect(find.text('Ready to split something?'), findsOneWidget);
  });
}
