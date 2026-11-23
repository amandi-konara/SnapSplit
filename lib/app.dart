import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class SnapSplitApp extends ConsumerWidget {
  const SnapSplitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SnapSplit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // The mockups are light-only.
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
