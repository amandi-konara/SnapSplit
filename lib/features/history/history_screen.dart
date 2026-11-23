import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// S06 History: search by store, receipts grouped by month. (Track D)
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      showAppBar: false,
      title: 'History',
      subtitle: 'All your split receipts.',
      track: 'Track D · lib/features/history',
      requirements: 'FR-12',
      actions: [
        PlaceholderAction(
          'Open sample receipt',
          (c) => c.push(Routes.receipt('r-keells')),
        ),
      ],
    );
  }
}
