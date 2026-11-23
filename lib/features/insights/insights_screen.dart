import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// Insights: spending by category (donut) and "Most shared with". (Track D)
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      showAppBar: false,
      title: 'Insights',
      subtitle: 'Where your money goes. 📊',
      track: 'Track D · lib/features/insights',
      requirements: 'FR-11 (across receipts)',
    );
  }
}
