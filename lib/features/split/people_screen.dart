import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// "Who's sharing this? 👥" - pick or add people. (Track C)
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: "Who's sharing this? 👥",
      subtitle: 'Pick the people on this receipt.',
      track: 'Track C · lib/features/split',
      requirements: 'FR-08',
      actions: [
        PlaceholderAction('Continue with 2 →', (c) => c.push(Routes.assign)),
      ],
    );
  }
}
