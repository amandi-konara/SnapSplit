import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// Profile: My People, Categories, Notifications, Help, Log out. (Track D)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    return PlaceholderScreen(
      showAppBar: false,
      title: user?.displayName ?? 'Profile',
      subtitle: user?.email ?? '',
      track: 'Track D · lib/features/profile',
      requirements: 'FR-01, FR-08',
      actions: [
        PlaceholderAction(
          'My People',
          (c) => c.push(Routes.myPeople),
          primary: false,
        ),
        PlaceholderAction(
          'Categories',
          (c) => c.push(Routes.myCategories),
          primary: false,
        ),
        // The router shows Login on its own after sign-out.
        PlaceholderAction(
          'Log out',
          (_) => ref.read(authRepositoryProvider).signOut(),
        ),
      ],
    );
  }
}
