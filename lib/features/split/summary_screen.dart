import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// S05 "All split up! 🎉" - total, who pays what, where the money went,
/// Save receipt. (Track C)
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'All split up! 🎉',
      subtitle: "Here's how everyone's share landed.",
      track: 'Track C · lib/features/split',
      requirements: 'FR-11, FR-14',
      actions: [
        PlaceholderAction('Save receipt ✓', (c) {
          ScaffoldMessenger.of(c)
              .showSnackBar(const SnackBar(content: Text('Receipt saved! ✓')));
          c.go(Routes.home);
        }),
      ],
    );
  }
}
