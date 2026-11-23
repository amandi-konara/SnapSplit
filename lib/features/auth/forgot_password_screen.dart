import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// "Reset password" - sends a reset link by email. (Track B)
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Reset password',
      subtitle: "We'll send you a link to reset it",
      track: 'Track B · lib/features/auth',
      requirements: 'FR-01',
    );
  }
}
