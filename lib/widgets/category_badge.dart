import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';

/// A category's emoji in a soft rounded square.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.size = 32});

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(category.emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

/// Finds a category by id in [all], falling back to a built-in one, then to
/// "Other". Never returns null, so screens don't have to handle a missing
/// category (e.g. a custom one that was deleted).
Category categoryFor(String id, [List<Category> all = const []]) {
  for (final c in all) {
    if (c.id == id) return c;
  }
  for (final c in Category.builtIn) {
    if (c.id == id) return c;
  }
  return Category.builtIn.last;
}
