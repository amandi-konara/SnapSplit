import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// S03 "I found N items! 🎉": store name, editable item rows, total.
/// (Track A)
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'I found 5 items! 🎉',
      subtitle: "Let's make sure I got everything right.",
      track: 'Track A · lib/features/scan',
      requirements: 'FR-05, FR-06',
      actions: [
        PlaceholderAction(
          'Looks good! Next →',
          (c) => c.push(Routes.categories),
        ),
      ],
    );
  }
}
