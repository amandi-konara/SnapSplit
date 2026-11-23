import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../widgets/placeholder_screen.dart';

/// S02 "Scan a receipt": camera frame, Take Photo / Gallery, then
/// "Reading your receipt..." while ML Kit runs. (Track A)
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Scan a receipt 📷',
      subtitle: 'Place the receipt inside the frame.',
      track: 'Track A · lib/features/scan',
      requirements: 'FR-02, FR-03, FR-04',
      actions: [
        PlaceholderAction('Take Photo', (c) => c.push(Routes.review)),
        PlaceholderAction(
          'Gallery',
          (c) => c.push(Routes.review),
          primary: false,
        ),
      ],
    );
  }
}
