import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/history/history_screen.dart';
import '../features/history/receipt_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/profile/my_categories_screen.dart';
import '../features/profile/my_people_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/scan/review_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/split/assign_screen.dart';
import '../features/split/categories_screen.dart';
import '../features/split/people_screen.dart';
import '../features/split/summary_screen.dart';
import '../models/models.dart';
import 'app_shell.dart';
import 'routes.dart';

/// The app's router.
///
/// Auth guard: signed-out users only see the login, register and forgot
/// password screens; signed-in users are sent away from them. Screens never
/// navigate after signing in or out - they only change the auth state.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final user = ValueNotifier<AppUser?>(auth.currentUser);
  final sub = auth.authStateChanges().listen((u) => user.value = u);
  ref.onDispose(() {
    sub.cancel();
    user.dispose();
  });

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: user,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final signedIn = user.value != null;
      final onAuthPage = Routes.authRoutes.contains(state.matchedLocation);
      if (!signedIn && !onAuthPage) return Routes.login;
      if (signedIn && onAuthPage) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.home),

      // Auth (Track B)
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),

      // Bottom-nav tabs
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (_, _) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.insights,
                builder: (_, _) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen pages (no bottom bar)
      GoRoute(path: Routes.scan, builder: (_, _) => const ScanScreen()),
      GoRoute(path: Routes.review, builder: (_, _) => const ReviewScreen()),
      GoRoute(
        path: Routes.categories,
        builder: (_, _) => const CategoriesScreen(),
      ),
      GoRoute(path: Routes.people, builder: (_, _) => const PeopleScreen()),
      GoRoute(path: Routes.assign, builder: (_, _) => const AssignScreen()),
      GoRoute(path: Routes.summary, builder: (_, _) => const SummaryScreen()),
      GoRoute(
        path: Routes.receiptPattern,
        builder: (_, state) =>
            ReceiptDetailScreen(receiptId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.myPeople, builder: (_, _) => const MyPeopleScreen()),
      GoRoute(
        path: Routes.myCategories,
        builder: (_, _) => const MyCategoriesScreen(),
      ),
    ],
  );
});
