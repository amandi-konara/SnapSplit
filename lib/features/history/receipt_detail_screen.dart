import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../models/models.dart';
import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// A saved receipt: total, who pays what, where the money went, items,
/// and Edit. (Track D)
class ReceiptDetailScreen extends ConsumerWidget {
  const ReceiptDetailScreen({super.key, required this.receiptId});

  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.watch(receiptByIdProvider(receiptId)).value;
    return PlaceholderScreen(
      title: receipt?.storeName ?? 'Receipt',
      subtitle: receipt == null
          ? 'Loading…'
          : '${formatRs(receipt.totalCents)} · '
                '${receipt.personIds.length} people sharing',
      track: 'Track D · lib/features/history',
      requirements: 'FR-11, FR-13',
      actions: [
        PlaceholderAction(
          'Edit receipt',
          (c) => c.push(Routes.review),
          primary: false,
        ),
      ],
    );
  }
}
