import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

/// Shown by the scan-to-split steps when there is no receipt in progress
/// (for example after the app was restarted on one of these pages).
class NoDraftView extends StatelessWidget {
  const NoDraftView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          EmptyState(
            title: 'No receipt in progress',
            message: 'Scan a receipt to start splitting.',
            action: FilledButton(
              onPressed: () => context.go(Routes.scan),
              child: const Text('Scan a receipt'),
            ),
          ),
        ],
      ),
    );
  }
}
