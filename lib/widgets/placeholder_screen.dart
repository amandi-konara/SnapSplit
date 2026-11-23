import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'mascot.dart';

/// A button on a [PlaceholderScreen] that moves through the app.
class PlaceholderAction {
  const PlaceholderAction(this.label, this.onPressed, {this.primary = true});
  final String label;
  final void Function(BuildContext context) onPressed;
  final bool primary;
}

/// Temporary screen used until a track builds the real one. It shows what
/// the screen is for and who owns it, and has buttons so the whole flow can
/// be clicked through from Day 1.
///
/// Delete each usage once the real screen exists.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.track,
    required this.requirements,
    this.eyebrow,
    this.actions = const [],
    this.showAppBar = true,
  });

  final String title;
  final String subtitle;

  /// Owning track, e.g. "Track C · lib/features/split".
  final String track;

  /// Proposal requirement ids this screen covers, e.g. "FR-09, FR-10".
  final String requirements;

  final String? eyebrow;
  final List<PlaceholderAction> actions;

  /// False for the bottom-nav tabs, which have no back button.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: showAppBar ? AppBar() : null,
      body: SafeArea(
        top: !showAppBar,
        child: ListView(
          padding: AppSpacing.page.copyWith(
            top: showAppBar ? 0 : AppSpacing.xl,
            bottom: AppSpacing.xl,
          ),
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!,
                style: text.bodySmall!.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(title, style: text.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: text.bodyMedium!.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Center(child: Mascot(size: 180)),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.coralSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        color: AppColors.coral,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Being built by $track', style: text.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Covers $requirements',
                            style: text.bodySmall!.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final action in actions) ...[
              const SizedBox(height: AppSpacing.md),
              action.primary
                  ? FilledButton(
                      onPressed: () => action.onPressed(context),
                      child: Text(action.label),
                    )
                  : OutlinedButton(
                      onPressed: () => action.onPressed(context),
                      child: Text(action.label),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
