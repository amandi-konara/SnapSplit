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
    await tap('Looks good! Next →');
    await tap('Next →');
    await tap('Continue with 2 →');
    await tap('Continue to summary →');
    expect(find.text('All split up! 🎉'), findsOneWidget);
    await tap('Save receipt ✓');
    expect(find.text('Ready to split something?'), findsOneWidget);
  });
}
