import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../data/repositories.dart';
import '../../models/models.dart';
import '../../router/routes.dart';
import '../../widgets/step_scaffold.dart';
import 'assign_screen.dart' show peopleById;
import 'draft_receipt.dart';
import 'no_draft_view.dart';
import 'split_summary_view.dart';

/// S05 "All split up! 🎉": the final breakdown and Save (FR-11, FR-14).
class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _saving = false;

  Future<void> _save(DraftReceipt draft) async {
    // Items must be confirmed against the printed total before saving
    // (proposal Appendix B, NFR-07).
    final diff = draft.receipt.printedTotalDifference;
    if (diff != null && diff != 0) {
      final ok = await _confirmMismatch(draft.receipt);
      if (ok != true || !mounted) return;
    }

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(draftReceiptProvider.notifier).save();
      if (!mounted) return;
      context.go(Routes.home);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Receipt saved! ✓')));
    } on DataException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't save the receipt. Try again.")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool?> _confirmMismatch(Receipt receipt) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Totals don't match"),
      content: Text(
        'The items add up to ${formatRs(receipt.totalCents)}, but the '
        'receipt says ${formatRs(receipt.printedTotalCents!)}. '
        'Save anyway?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Go back'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Save anyway'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(draftReceiptProvider);
    if (draft == null) return const NoDraftView();

    return StepScaffold(
      title: 'All split up! 🎉',
      subtitle: "Here's how everyone's share landed.",
      bottom: FilledButton(
        onPressed: _saving || !draft.isFullyAssigned
            ? null
            : () => _save(draft),
        child: Text(_saving ? 'Saving…' : 'Save receipt ✓'),
      ),
      children: [
        SplitSummaryView(
          receipt: draft.receipt,
          people: peopleById(ref.watch(peopleProvider).value),
          categories: ref.watch(categoriesProvider).value ?? Category.builtIn,
        ),
      ],
    );
  }
}
