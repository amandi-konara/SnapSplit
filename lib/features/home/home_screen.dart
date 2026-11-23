import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// S01 Home: greeting, big "Scan Receipt" card, recent receipts. (Track D)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    return PlaceholderScreen(
      showAppBar: false,
      eyebrow: 'Hey ${user?.firstName ?? 'there'}! 👋',
      title: 'Ready to split something?',
      subtitle: 'Recent receipts will be listed here.',
      track: 'Track D · lib/features/home',
      requirements: 'S01',
      actions: [PlaceholderAction('Scan Receipt', (c) => c.push(Routes.scan))],
    );
  }
}
