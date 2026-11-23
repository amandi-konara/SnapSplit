import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// "Categories 🏷️" - built-in (locked) and your own. (Track D)
class MyCategoriesScreen extends StatelessWidget {
  const MyCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Categories 🏷️',
      subtitle: 'What kind of things did you buy?',
      track: 'Track D · lib/features/profile',
      requirements: 'FR-07',
    );
  }
}
