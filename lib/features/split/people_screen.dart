import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../data/repositories.dart';
import '../../models/models.dart';
import '../../router/routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/person_avatar.dart';
import '../../widgets/step_scaffold.dart';
import 'draft_receipt.dart';
import 'no_draft_view.dart';

/// "Who's sharing this? 👥": pick saved people or add new ones (FR-08).
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final _name = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    if (name.isEmpty || _adding) return;
    setState(() => _adding = true);
    try {
      final person = await ref.read(peopleRepositoryProvider).add(name);
      ref.read(draftReceiptProvider.notifier).togglePerson(person.id);
      _name.clear();
    } on DataException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(draftReceiptProvider);
    if (draft == null) return const NoDraftView();
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final ctrl = ref.read(draftReceiptProvider.notifier);
    final count = draft.personIds.length;

    return StepScaffold(
      title: "Who's sharing this? 👥",
      subtitle: 'Pick the people on this receipt.',
      bottom: FilledButton(
        onPressed: count == 0
            ? null
            : () {
                ctrl.prepareAssignments();
                context.push(Routes.assign);
              },
        child: Text('Continue with $count →'),
      ),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final person in people)
              _PersonChip(
                person: person,
                selected: draft.personIds.contains(person.id),
                onTap: () => ctrl.togglePerson(person.id),
              ),
          ],
        ),
        if (people.isNotEmpty) const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                decoration: const InputDecoration(hintText: 'Add someone new…'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox.square(
              dimension: 50,
              child: IconButton.outlined(
                tooltip: 'Add person',
                onPressed: _adding ? null : _add,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, color: AppColors.coral),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonChip extends StatelessWidget {
  const _PersonChip({
    required this.person,
    required this.selected,
    required this.onTap,
  });

  final Person person;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceTint : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(
          color: selected ? AppColors.coralFaded : AppColors.line,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PersonAvatar(person: person, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text(person.name, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: AppSpacing.sm),
              CheckDot(checked: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coral filled tick when on, empty circle when off.
class CheckDot extends StatelessWidget {
  const CheckDot({super.key, required this.checked, this.size = 20});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? AppColors.coral : Colors.transparent,
        border: Border.all(
          color: checked ? AppColors.coral : AppColors.line,
          width: 1.5,
        ),
      ),
      child: checked
          ? Icon(Icons.check_rounded, size: size * 0.7, color: Colors.white)
          : null,
    );
  }
}
