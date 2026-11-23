import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// "Create your account". (Track B)
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Create your account',
      subtitle: 'Sign up to get started',
      track: 'Track B · lib/features/auth',
      requirements: 'FR-01',
    );
  }
}
