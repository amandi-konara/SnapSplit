import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Layout for the scan-to-split steps and other full-screen pages:
/// back button, heavy title + grey subtitle, scrolling body, and a button
/// bar pinned to the bottom ("Looks good! Next →").
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.bottom,
    this.actions,
  });

  final String title;
  final String? subtitle;

  /// Body content, laid out in a scrolling column with page padding.
  final List<Widget> children;

  /// Pinned under the body, usually a [FilledButton]. Can also hold a
  /// running-total card above the button.
  final Widget? bottom;

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(actions: actions),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: AppSpacing.page.copyWith(bottom: AppSpacing.xl),
              children: [
                Text(title, style: text.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: text.bodyMedium!.copyWith(color: AppColors.inkMuted),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                ...children,
              ],
            ),
          ),
          if (bottom != null) BottomBar(child: bottom!),
        ],
      ),
    );
  }
}

/// White bar with a top border, pinned to the bottom of a screen.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.page.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A white card with a bold title, used for "Who pays what",
/// "Where the money went" and similar groups.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
