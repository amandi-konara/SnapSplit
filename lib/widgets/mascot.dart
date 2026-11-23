import 'package:flutter/material.dart';

/// The SnapSplit mascot (receipt with a magnifying glass).
///
/// Used on the splash screen, empty states and the OCR loading screen.
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.size = 160});

  /// Width of the image; height follows the 4:3 artwork.
  final double size;

  static const asset = 'assets/branding/logo.webp';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size * 3 / 4,
      fit: BoxFit.contain,
      semanticLabel: 'SnapSplit mascot',
      errorBuilder: (_, _, _) => SizedBox(
        width: size,
        height: size * 3 / 4,
        child: const Center(child: Text('🧾', style: TextStyle(fontSize: 48))),
      ),
    );
  }
}
