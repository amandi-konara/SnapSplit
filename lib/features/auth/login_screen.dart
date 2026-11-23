import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// "Welcome back" - email/password login. (Track B)
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      showAppBar: false,
      title: 'Welcome back',
      subtitle: 'Log in to your account',
      track: 'Track B · lib/features/auth',
      requirements: 'FR-01',
      actions: [
        // The router moves to Home on its own once the user is signed in.
        PlaceholderAction(
          'Log in with demo account',
          (_) => ref
              .read(authRepositoryProvider)
              .signIn(email: 'demo@snapsplit.app', password: 'demo1234'),
        ),
        PlaceholderAction(
          'Create an account',
          (c) => c.push(Routes.register),
          primary: false,
        ),
        PlaceholderAction(
          'Forgot password?',
          (c) => c.push(Routes.forgotPassword),
          primary: false,
        ),
      ],
    );
  }
}
