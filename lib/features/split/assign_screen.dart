import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// "Who bought what?" - Equal / Exact / Percent per item, with the running
/// total. (Track C)
class AssignScreen extends StatelessWidget {
  const AssignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Who bought what? 👥',
      subtitle: "Tap people for each item — we'll do the math.",
      track: 'Track C · lib/features/split',
      requirements: 'FR-09, FR-10',
      actions: [
        PlaceholderAction(
          'Continue to summary →',
          (c) => c.push(Routes.summary),
        ),
      ],
    );
  }
}
