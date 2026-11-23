import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../router/routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/step_scaffold.dart';
import '../split/draft_receipt.dart';
import '../split/no_draft_view.dart';

/// S03 "I found N items! 🎉": check and fix what OCR read before anything
/// is calculated (FR-05, FR-06, NFR-07).
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftReceiptProvider);
    if (draft == null) return const NoDraftView();
    final ctrl = ref.read(draftReceiptProvider.notifier);
    final receipt = draft.receipt;
    final count = draft.items.length;

    final (title, subtitle) = draft.isEditing
        ? (
            'Edit receipt ✏️',
            'Change anything, then go through the steps again.',
          )
        : count == 0
        ? ("Let's add the items ✍️", 'Type each item and its price.')
        : (
            'I found $count item${count == 1 ? '' : 's'}! 🎉',
            "Let's make sure I got everything right.",
          );

    return StepScaffold(
      title: title,
      subtitle: subtitle,
      bottom: FilledButton(
        onPressed: draft.isReviewComplete
            ? () => context.push(Routes.categories)
            : null,
        child: const Text('Looks good! Next →'),
      ),
      children: [
        const _Label('STORE'),
        _StoreField(initial: receipt.storeName, onChanged: ctrl.setStoreName),
        const SizedBox(height: AppSpacing.md),
        const _Label('DATE'),
        _DateField(date: receipt.date, onChanged: ctrl.setDate),
        const SizedBox(height: AppSpacing.lg),
        for (final item in draft.items) ...[
          _ItemRow(
            key: ValueKey(item.id),
            item: item,
            onName: (v) => ctrl.editItem(item.id, name: v),
            onAmount: (v) => ctrl.editItem(item.id, amountCents: v),
            onDelete: () => ctrl.removeItem(item.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        OutlinedButton.icon(
          onPressed: ctrl.addItem,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.coral,
            minimumSize: const Size.fromHeight(46),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add item'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _TotalPill(totalCents: receipt.totalCents),
        const SizedBox(height: AppSpacing.sm),
        ..._hints(draft),
      ],
    );
  }

  /// Explains why Next is disabled, and whether the items match the total
  /// printed on the receipt (UX principle: show reconciliation).
  List<Widget> _hints(DraftReceipt draft) {
    final receipt = draft.receipt;
    final hints = <Widget>[];
    if (receipt.storeName.trim().isEmpty) {
      hints.add(const StatusChip('Add the store name to continue.'));
    } else if (draft.items.isEmpty) {
      hints.add(const StatusChip('Add at least one item to continue.'));
    } else if (!draft.isReviewComplete) {
      hints.add(const StatusChip('Every item needs a name and a price.'));
    }
    final diff = receipt.printedTotalDifference;
    if (diff != null && draft.items.isNotEmpty) {
      hints.add(
        diff == 0
            ? const StatusChip.success('Matches the total on the receipt.')
            : StatusChip.warning(
                'Items add up to ${formatRs(receipt.totalCents)}, but the '
                'receipt says ${formatRs(receipt.printedTotalCents!)}. '
                'Check for missing or misread items.',
              ),
      );
    }
    return [
      for (final h in hints) ...[h, const SizedBox(height: AppSpacing.sm)],
    ];
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall!
          .copyWith(color: AppColors.inkMuted, letterSpacing: 0.8),
    ),
  );
}

class _StoreField extends StatefulWidget {
  const _StoreField({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_StoreField> createState() => _StoreFieldState();
}

class _StoreFieldState extends State<_StoreField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: widget.onChanged,
    textCapitalization: TextCapitalization.words,
    decoration: const InputDecoration(hintText: 'Store name'),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date.isAfter(now) ? now : date,
          firstDate: DateTime(2000),
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(DateFormat('EEE, d MMM yyyy').format(date)),
      ),
    );
  }
}

/// One editable item: name, price in rupees, delete.
class _ItemRow extends StatefulWidget {
  const _ItemRow({
    super.key,
    required this.item,
    required this.onName,
    required this.onAmount,
    required this.onDelete,
  });

  final ReceiptItem item;
  final ValueChanged<String> onName;
  final ValueChanged<Cents> onAmount;
  final VoidCallback onDelete;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  late final _name = TextEditingController(text: widget.item.name);
  late final _amount = TextEditingController(
    text: widget.item.amountCents == 0 ? '' : _plain(widget.item.amountCents),
  );

  /// 45000 -> "450", 45050 -> "450.50" (no "Rs." or commas, for editing).
  static String _plain(Cents c) =>
      c % 100 == 0 ? '${c ~/ 100}' : (c / 100).toStringAsFixed(2);

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invalidAmount =
        _amount.text.isNotEmpty && parseRs(_amount.text) == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _name,
                onChanged: widget.onName,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Item name'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _amount,
                onChanged: (v) {
                  setState(() {}); // refresh the error state
                  widget.onAmount(parseRs(v) ?? 0);
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  prefixText: 'Rs. ',
                  hintText: '0',
                  errorText: invalidAmount ? 'Check price' : null,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Delete item',
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalPill extends StatelessWidget {
  const _TotalPill({required this.totalCents});
  final Cents totalCents;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Text('Total', style: text.bodyMedium),
          const Spacer(),
          Text(formatRs(totalCents), style: text.titleMedium),
        ],
      ),
    );
  }
}
