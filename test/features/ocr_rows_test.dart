import 'package:flutter_test/flutter_test.dart';
import 'package:snapsplit/features/scan/ocr_service.dart';

void main() {
  OcrLine line(String text, double left, double top) =>
      OcrLine(text, left: left, top: top, bottom: top + 20);

  test('name and price far apart on one row are joined, left to right', () {
    final rows = groupIntoRows([
      line('500.00', 400, 101),
      line('SAMBA RICE', 20, 100),
      line('KEELLS', 150, 40),
      line('850.00', 400, 139),
      line('SHAMPOO', 20, 142),
    ]);
    expect(rows, ['KEELLS', 'SAMBA RICE  500.00', 'SHAMPOO  850.00']);
  });

  test('empty input gives no rows', () {
    expect(groupIntoRows([]), isEmpty);
  });
}
