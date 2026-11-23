import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/models.dart';
import '../../router/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/step_scaffold.dart';
import 'draft_receipt.dart';
import 'no_draft_view.dart';

/// "What kind of things? 🏷️": one category per item, pre-filled with a
/// suggestion (FR-07). Kept separate from who pays (UX principle).
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftReceiptProvider);
    if (draft == null) return const NoDraftView();
    final categories = ref.watch(categoriesProvider).value ?? Category.builtIn;

    return StepScaffold(
      title: 'What kind of things? 🏷️',
      subtitle: 'We suggested categories — tweak any you like.',
      bottom: FilledButton(
        onPressed: () => context.push(Routes.people),
        child: const Text('Next →'),
      ),
      children: [
        for (final item in draft.items) ...[
          _CategoryCard(
            item: item,
            categories: categories,
            onChanged: (id) => ref
                .read(draftReceiptProvider.notifier)
                .setCategory(item.id, id),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.item,
    required this.categories,
    required this.onChanged,
  });

  final ReceiptItem item;
  final List<Category> categories;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final current = categoryFor(item.categoryId, categories);
    // Make sure the current value is in the list (e.g. a deleted custom one).
    final options = [
      ...categories,
      if (!categories.any((c) => c.id == current.id)) current,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.name, style: text.titleSmall)),
                Text(formatRs(item.amountCents), style: text.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CategoryBadge(category: current, size: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: current.id,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    items: [
                      for (final c in options)
                        DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.emoji}  ${c.name}'),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) onChanged(id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
