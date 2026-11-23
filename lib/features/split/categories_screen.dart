import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// "What kind of things? 🏷️" - a suggested category per item. (Track C)
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'What kind of things? 🏷️',
      subtitle: 'We suggested categories — tweak any you like.',
      track: 'Track C · lib/features/split',
      requirements: 'FR-07',
      actions: [PlaceholderAction('Next →', (c) => c.push(Routes.people))],
    );
  }
}
