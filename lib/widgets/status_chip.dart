import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum StatusKind { success, warning, info }

/// Full-width soft chip for states like "✓ All assigned!" (mint) or
/// "Rs. 450 still to assign" (amber).
class StatusChip extends StatelessWidget {
  const StatusChip(this.message, {super.key, this.kind = StatusKind.info});

  const StatusChip.success(this.message, {super.key})
    : kind = StatusKind.success;

  const StatusChip.warning(this.message, {super.key})
    : kind = StatusKind.warning;

  final String message;
  final StatusKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (kind) {
      StatusKind.success => (
        AppColors.mintSoft,
        AppColors.mintInk,
        Icons.check_rounded,
      ),
      StatusKind.warning => (
        AppColors.warningSoft,
        AppColors.warningInk,
        Icons.warning_amber_rounded,
      ),
      StatusKind.info => (
        AppColors.surfaceTint,
        AppColors.inkMuted,
        Icons.info_outline_rounded,
      ),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium!
                  .copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
