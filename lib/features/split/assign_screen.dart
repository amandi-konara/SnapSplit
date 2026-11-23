import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/models.dart';
import '../../router/routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/person_avatar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/step_scaffold.dart';
import 'draft_receipt.dart';
import 'no_draft_view.dart';
import 'people_screen.dart' show CheckDot;

/// "Who bought what?": per item, tick who pays and choose Equal, Exact or
/// Percent (FR-09, FR-10). The running total stays visible at the bottom.
class AssignScreen extends ConsumerWidget {
  const AssignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftReceiptProvider);
    if (draft == null) return const NoDraftView();
    final people = peopleById(ref.watch(peopleProvider).value);
    final receiptPeople = [
      for (final id in draft.personIds) people[id] ?? unknownPerson(id),
    ];

    return StepScaffold(
      title: 'Who bought what? 👥',
      subtitle: "Tap people for each item — we'll do the math.",
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RunningTotal(draft: draft, people: receiptPeople),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: draft.isFullyAssigned
                ? () => context.push(Routes.summary)
                : null,
            child: const Text('Continue to summary →'),
          ),
        ],
      ),
      children: [
        for (final item in draft.items) ...[
          _ItemSplitCard(item: item, people: receiptPeople),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// People by id, for looking up names and avatars.
Map<String, Person> peopleById(List<Person>? people) => {
  for (final p in people ?? const <Person>[]) p.id: p,
};

/// Stand-in for a person who was deleted after being put on a receipt.
Person unknownPerson(String id) => Person(id: id, name: 'Someone');

class _ItemSplitCard extends ConsumerWidget {
  const _ItemSplitCard({required this.item, required this.people});

  final ReceiptItem item;
  final List<Person> people;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final ctrl = ref.read(draftReceiptProvider.notifier);
    final byPerson = {for (final a in item.assignments) a.personId: a};

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
            _MethodSwitch(
              value: item.splitMethod,
              onChanged: (m) => ctrl.setSplitMethod(item.id, m),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final person in people) ...[
              _PersonRow(
                // A new key per method resets typed values when switching.
                key: ValueKey('${item.id}-${person.id}-${item.splitMethod}'),
                person: person,
                method: item.splitMethod,
                assignment: byPerson[person.id],
                onToggle: () => ctrl.toggleItemPerson(item.id, person.id),
                onShare: (v) => ctrl.setShare(item.id, person.id, v),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            _itemStatus(item),
          ],
        ),
      ),
    );
  }

  Widget _itemStatus(ReceiptItem item) {
    if (item.assignments.isEmpty) {
      return const StatusChip.warning('Tick at least one person.');
    }
    final left = item.unassignedCents;
    if (left > 0) {
      return StatusChip.warning('${formatRs(left)} still to assign.');
    }
    if (left < 0) {
      return StatusChip.warning('${formatRs(-left)} more than the item price.');
    }
    return const StatusChip.success('All assigned!');
  }
}

/// Equal | Exact | Percent.
class _MethodSwitch extends StatelessWidget {
  const _MethodSwitch({required this.value, required this.onChanged});

  final SplitMethod value;
  final ValueChanged<SplitMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadii.sm + 2),
      ),
      child: Row(
        children: [
          for (final method in SplitMethod.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: method == value,
                child: GestureDetector(
                  onTap: () => onChanged(method),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: method == value
                          ? AppColors.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: method == value
                          ? Border.all(color: AppColors.line)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      method.label,
                      style: text.labelMedium!.copyWith(
                        color: method == value
                            ? AppColors.coral
                            : AppColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One person on one item: tick, avatar, name, and their share.
class _PersonRow extends StatefulWidget {
  const _PersonRow({
    super.key,
    required this.person,
    required this.method,
    required this.assignment,
    required this.onToggle,
    required this.onShare,
  });

  final Person person;
  final SplitMethod method;
  final Assignment? assignment;
  final VoidCallback onToggle;
  final ValueChanged<int?> onShare;

  @override
  State<_PersonRow> createState() => _PersonRowState();
}

class _PersonRowState extends State<_PersonRow> {
  late final _controller = TextEditingController(text: _initialText());

  String _initialText() {
    final share = widget.assignment?.share;
    if (share == null) return '';
    return switch (widget.method) {
      SplitMethod.exact =>
        share % 100 == 0 ? '${share ~/ 100}' : (share / 100).toStringAsFixed(2),
      SplitMethod.percentage => formatPercent(share).replaceAll('%', ''),
      SplitMethod.equal => '',
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final on = widget.assignment != null;
    final allocated = widget.assignment?.allocatedCents ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: on ? AppColors.surfaceTint : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onToggle,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CheckDot(checked: on),
            ),
          ),
          const SizedBox(width: 6),
          PersonAvatar(person: widget.person, size: 26),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: widget.onToggle,
              behavior: HitTestBehavior.opaque,
              child: Text(widget.person.name, style: text.labelLarge),
            ),
          ),
          SizedBox(
            height: 40,
            child: Center(child: _trailing(on, allocated, text)),
          ),
        ],
      ),
    );
  }

  Widget _trailing(bool on, Cents allocated, TextTheme text) {
    if (!on) {
      return Text(
        '—',
        style: text.labelLarge!.copyWith(color: AppColors.inkMuted),
      );
    }
    switch (widget.method) {
      case SplitMethod.equal:
        return Text(formatRs(allocated), style: text.labelLarge);
      case SplitMethod.exact:
        return _field(prefix: 'Rs. ', width: 104, parse: parseRs);
      case SplitMethod.percentage:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(suffix: '%', width: 76, parse: _parsePercent),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 72,
              child: Text(
                formatRs(allocated),
                textAlign: TextAlign.end,
                style: text.labelMedium!.copyWith(color: AppColors.inkMuted),
              ),
            ),
          ],
        );
    }
  }

  Widget _field({
    String? prefix,
    String? suffix,
    required double width,
    required int? Function(String) parse,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: _controller,
        onChanged: (v) => widget.onShare(v.trim().isEmpty ? null : parse(v)),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.labelLarge,
        decoration: InputDecoration(
          isDense: true,
          prefixText: prefix,
          suffixText: suffix,
          hintText: '0',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  /// "12.5" -> 1250 basis points. Null if not a number up to 100 with at
  /// most two decimals.
  static BasisPoints? _parsePercent(String input) {
    final m = RegExp(r'^(\d{1,3})(?:\.(\d{0,2}))?$').firstMatch(input.trim());
    if (m == null) return null;
    final value =
        int.parse(m.group(1)!) * 100 +
        int.parse((m.group(2) ?? '').padRight(2, '0'));
    return value > fullPercent ? null : value;
  }
}

/// RUNNING TOTAL card: each person's total so far, and whether it all adds
/// up to the receipt total.
class _RunningTotal extends StatelessWidget {
  const _RunningTotal({required this.draft, required this.people});

  final DraftReceipt draft;
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final totals = draft.receipt.totalsByPerson;
    final left = draft.unassignedCents;
    final missingPeople = draft.items.any((i) => i.assignments.isEmpty);

    final (status, color, icon) = draft.isFullyAssigned
        ? ('Everything adds up!', AppColors.mintInk, Icons.check_rounded)
        : missingPeople
        ? (
            'Some items have nobody ticked.',
            AppColors.warningInk,
            Icons.warning_amber_rounded,
          )
        : left > 0
        ? (
            '${formatRs(left)} still unassigned.',
            AppColors.warningInk,
            Icons.warning_amber_rounded,
          )
        : (
            '${formatRs(-left)} assigned too much.',
            AppColors.warningInk,
            Icons.warning_amber_rounded,
          );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'RUNNING TOTAL',
                style: text.labelSmall!.copyWith(
                  color: AppColors.inkMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(formatRs(draft.receipt.totalCents), style: text.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final p in people)
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PersonAvatar(person: p, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${p.name} ${formatRs(totals[p.id] ?? 0)}',
                        style: text.labelMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(status, style: text.labelMedium!.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
