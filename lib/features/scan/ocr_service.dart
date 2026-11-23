import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Reads the text on a receipt photo, one string per printed row
/// (proposal FR-04).
abstract interface class OcrService {
  /// False on platforms without ML Kit (web, desktop); the app then asks the
  /// user to type the items in.
  bool get isSupported;

  Future<List<String>> readRows(String imagePath);
}

final ocrServiceProvider = Provider<OcrService>((ref) => MlKitOcrService());

/// On-device text recognition with Google ML Kit (Android and iOS).
class MlKitOcrService implements OcrService {
  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<List<String>> readRows(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return groupIntoRows([
        for (final block in result.blocks)
          for (final line in block.lines)
            OcrLine(
              line.text,
              left: line.boundingBox.left,
              top: line.boundingBox.top,
              bottom: line.boundingBox.bottom,
            ),
      ]);
    } finally {
      await recognizer.close();
    }
  }
}

/// One piece of text ML Kit found, with its position on the photo.
class OcrLine {
  const OcrLine(
    this.text, {
    required this.left,
    required this.top,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double bottom;

  double get centerY => (top + bottom) / 2;
  double get height => bottom - top;
}

/// Puts ML Kit's text pieces back into printed rows.
///
/// ML Kit often returns an item's name and its price as separate pieces
/// (they are far apart on the paper). Pieces whose vertical centres are
/// within half a line height of each other are treated as one row, then
/// read left to right.
List<String> groupIntoRows(List<OcrLine> lines) {
  if (lines.isEmpty) return const [];
  final sorted = [...lines]..sort((a, b) => a.centerY.compareTo(b.centerY));
  final heights = [for (final l in sorted) l.height]..sort();
  final tolerance = heights[heights.length ~/ 2] * 0.5;

  final rows = <List<OcrLine>>[];
  for (final line in sorted) {
    final row = rows.isEmpty ? null : rows.last;
    if (row != null) {
      final rowCenter =
          row.fold<double>(0, (s, l) => s + l.centerY) / row.length;
      if ((line.centerY - rowCenter).abs() <= tolerance) {
        row.add(line);
        continue;
      }
    }
    rows.add([line]);
  }

  return [
    for (final row in rows)
      ([...row]..sort((a, b) => a.left.compareTo(b.left)))
          .map((l) => l.text.trim())
          .where((t) => t.isNotEmpty)
          .join('  '),
  ];
}
