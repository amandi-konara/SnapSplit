import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/person_avatar.dart';
import '../../widgets/step_scaffold.dart';
import 'assign_screen.dart' show unknownPerson;

/// The breakdown of a split receipt: total, who pays what, where the money
/// went (FR-11). Used on the Summary step and on a saved receipt's page.
class SplitSummaryView extends StatelessWidget {
  const SplitSummaryView({
    super.key,
    required this.receipt,
    required this.people,
    required this.categories,
    this.showItems = false,
  });

  final Receipt receipt;

  /// Saved people by id.
  final Map<String, Person> people;

  final List<Category> categories;

  /// Also list every item with who pays for it.
  final bool showItems;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final total = receipt.totalCents;
    final byPerson = receipt.totalsByPerson;
    final byCategory = receipt.totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sharing = receipt.personIds.length;

    Person person(String id) => people[id] ?? unknownPerson(id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          child: Column(
            children: [
              Text(
                'Total',
                style: text.labelMedium!.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatRs(total),
                style: text.headlineMedium!.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                '$sharing ${sharing == 1 ? 'person' : 'people'} sharing',
                style: text.bodySmall!.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Who pays what',
          children: [
            for (final id in receipt.personIds)
              _Row(
                leading: PersonAvatar(person: person(id), size: 32),
                label: person(id).name,
                value: formatRs(byPerson[id] ?? 0),
                bold: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Where the money went',
          children: [
            for (final entry in byCategory)
              _Row(
                leading: CategoryBadge(
                  category: categoryFor(entry.key, categories),
                ),
                label: categoryFor(entry.key, categories).name,
                detail: total == 0
                    ? null
                    : '${(entry.value * 100 / total).round()}%',
                value: formatRs(entry.value),
              ),
          ],
        ),
        if (showItems) ...[
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: 'Items',
            children: [
              for (final item in receipt.items)
                _Row(
                  leading: Text(
                    categoryFor(item.categoryId, categories).emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  label: item.name,
                  detail: [
                    for (final a in item.assignments) person(a.personId).name,
                  ].join(', '),
                  value: formatRs(item.amountCents),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.label,
    required this.value,
    this.detail,
    this.bold = false,
  });

  final Widget leading;
  final String label;
  final String? detail;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodyMedium),
                if (detail != null && detail!.isNotEmpty)
                  Text(
                    detail!,
                    style: text.bodySmall!.copyWith(color: AppColors.inkMuted),
                  ),
              ],
            ),
          ),
          Text(value, style: bold ? text.titleSmall : text.bodyMedium),
        ],
      ),
    );
  }
}
