import 'package:intl/intl.dart';

/// Money is always stored as whole cents (Rs. 450.50 -> 45050).
///
/// Never use `double` for money: 0.1 + 0.2 != 0.3 in floating point, and
/// split totals must add up exactly (proposal NFR-03).
typedef Cents = int;

/// Percentages are stored in basis points: 100% = 10000, 12.5% = 1250.
typedef BasisPoints = int;

const BasisPoints fullPercent = 10000;

final _whole = NumberFormat('#,##0', 'en_US');

/// Formats cents for display: 45000 -> "Rs. 450", 45050 -> "Rs. 450.50",
/// -1500 -> "-Rs. 15".
String formatRs(Cents cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final rupees = _whole.format(abs ~/ 100);
  final rest = abs % 100;
  final decimals = rest == 0 ? '' : '.${rest.toString().padLeft(2, '0')}';
  return '${sign}Rs. $rupees$decimals';
}

/// Parses user or OCR text into cents without going through `double`.
///
/// Accepts "450", "450.5", "450.50", "1,250.00", "Rs. 450", "Rs.450/=".
/// Returns null when the text is not a valid non-negative amount or has more
/// than two decimal places.
Cents? parseRs(String input) {
  var text = input.trim().toLowerCase();
  text = text.replaceAll(RegExp(r'^(rs\.?|lkr)\s*'), '');
  text = text.replaceAll(RegExp(r'/=?$'), '');
  text = text.replaceAll(',', '').replaceAll(' ', '');
  final match = RegExp(r'^(\d+)(?:\.(\d{0,2}))?$').firstMatch(text);
  if (match == null) return null;
  final rupees = int.parse(match.group(1)!);
  final decimals = (match.group(2) ?? '').padRight(2, '0');
  return rupees * 100 + int.parse(decimals);
}

/// Formats basis points as a percentage: 1250 -> "12.5%", 5000 -> "50%".
String formatPercent(BasisPoints bp) {
  final whole = bp ~/ 100;
  final rest = bp % 100;
  if (rest == 0) return '$whole%';
  final decimals = rest
      .toString()
      .padLeft(2, '0')
      .replaceAll(RegExp(r'0$'), '');
  return '$whole.$decimals%';
}
