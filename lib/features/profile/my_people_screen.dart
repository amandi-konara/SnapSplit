import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// "My People 👥" - add people with an emoji avatar, remove them. (Track D)
class MyPeopleScreen extends StatelessWidget {
  const MyPeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'My People 👥',
      subtitle: 'Save the people you split with often.',
      track: 'Track D · lib/features/profile',
      requirements: 'FR-08',
    );
  }
}
