import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/receipt_parser.dart';
import '../../router/routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mascot.dart';
import '../split/draft_receipt.dart';
import 'ocr_service.dart';

/// S02 "Scan a receipt 📷": photo from camera or gallery, then
/// "Reading your receipt…" while ML Kit runs (FR-02, FR-03, FR-04).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _reading = false;

  Future<void> _pick(ImageSource source) async {
    final XFile? photo;
    try {
      photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2400,
        imageQuality: 90,
      );
    } catch (_) {
      _show(
        source == ImageSource.camera
            ? "Couldn't open the camera. Check the camera permission in Settings."
            : "Couldn't open your photos. Check the photos permission in Settings.",
      );
      return;
    }
    if (photo == null || !mounted) return; // the user cancelled

    setState(() => _reading = true);
    final ocr = ref.read(ocrServiceProvider);
    ParsedReceipt? parsed;
    String? message;
    if (!ocr.isSupported) {
      message = 'Text reading works in the phone app. Type the items in here.';
    } else {
      try {
        parsed = ReceiptParser.parse(await ocr.readRows(photo.path));
        if (parsed.items.isEmpty) {
          message = "I couldn't find any items. You can type them in.";
        }
      } catch (_) {
        message =
            "Couldn't read that photo. Type the items in, or try again "
            'in better light.';
      }
    }
    if (!mounted) return;

    ref
        .read(draftReceiptProvider.notifier)
        .startNew(parsed: parsed, imagePath: kIsWeb ? null : photo.path);
    setState(() => _reading = false);
    if (message != null) _show(message);
    context.push(Routes.review);
  }

  void _typeItIn() {
    ref.read(draftReceiptProvider.notifier).startNew();
    context.push(Routes.review);
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_reading) return const _ReadingView();

    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.page.copyWith(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scan a receipt 📷', style: text.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Place the receipt inside the frame.',
                style: text.bodyMedium!.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Expanded(child: _ScanFrame()),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Keep it flat and make sure the text is visible.',
                  style: text.bodySmall!.copyWith(color: AppColors.inkMuted),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      icon: Icons.photo_camera_outlined,
                      label: 'Take Photo',
                      primary: true,
                      onPressed: () => _pick(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _BigButton(
                      icon: Icons.image_outlined,
                      label: 'Gallery',
                      primary: false,
                      onPressed: () => _pick(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: _typeItIn,
                  child: const Text('Type it in instead'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tall button with the icon above the label, as in the mockup.
class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 22), const SizedBox(height: 4), Text(label)],
    );
    const size = Size.fromHeight(72);
    return primary
        ? FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(minimumSize: size),
            child: content,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(minimumSize: size),
            child: content,
          );
  }
}

/// The dashed coral frame with corner marks and the mascot in the middle.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withValues(alpha: 0.18),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Mascot(size: 150),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 20.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );
    canvas.drawRRect(rect, Paint()..color = AppColors.surface);

    // Dashed outline.
    final dash = Paint()
      ..color = AppColors.coralFaded
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in (Path()..addRRect(rect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 5), dash);
      }
    }

    // Corner marks.
    final corner = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const inset = 16.0, arm = 26.0;
    final w = size.width, h = size.height;
    for (final (x, y, dx, dy) in [
      (inset, inset, 1.0, 1.0),
      (w - inset, inset, -1.0, 1.0),
      (inset, h - inset, 1.0, -1.0),
      (w - inset, h - inset, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(x, y), Offset(x + arm * dx, y), corner);
      canvas.drawLine(Offset(x, y), Offset(x, y + arm * dy), corner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Reading your receipt… 🔍" while OCR runs.
class _ReadingView extends StatelessWidget {
  const _ReadingView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(size: 160),
            const SizedBox(height: AppSpacing.lg),
            Text('Reading your receipt… 🔍', style: text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Finding the items…',
              style: text.bodySmall!.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SizedBox(width: 140, child: LinearProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
