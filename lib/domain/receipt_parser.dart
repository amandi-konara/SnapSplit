import '../models/models.dart';

/// What the parser could read from a receipt. Every field can be wrong or
/// missing, which is why the user always checks it on the Review screen
/// (proposal NFR-07).
class ParsedReceipt {
  const ParsedReceipt({
    this.storeName,
    this.date,
    this.totalCents,
    this.items = const [],
  });

  final String? storeName;
  final DateTime? date;

  /// The total printed on the receipt.
  final Cents? totalCents;

  final List<ParsedItem> items;
}

class ParsedItem {
  const ParsedItem(this.name, this.amountCents);
  final String name;
  final Cents amountCents;

  @override
  String toString() => '$name: $amountCents';
}

/// Turns OCR text rows into a store name, date, total and items.
///
/// Built for Sri Lankan supermarket and restaurant bills (Keells, Cargills,
/// Food City, Arpico...). It expects one string per printed row, left to
/// right, which is what `OcrService` produces.
abstract final class ReceiptParser {
  static const _knownStores = {
    'keells': 'Keells',
    'cargills': 'Cargills Food City',
    'food city': 'Cargills Food City',
    'arpico': 'Arpico',
    'spar': 'SPAR',
    'glomark': 'Glomark',
    'laugfs': 'LAUGFS',
    'sathosa': 'Sathosa',
    'healthguard': 'Healthguard',
    'pizza hut': 'Pizza Hut',
    'kfc': 'KFC',
    'pure foods': 'Pure Foods',
  };

  /// A money amount with exactly two decimals, e.g. 450.00 or 1,250.50.
  static final _money = RegExp(r'-?\d{1,3}(?:,\d{3})+\.\d{2}|-?\d+\.\d{2}');

  static final _totalLine = RegExp(
    r'\b(net\s*total|grand\s*total|total\s*amount|amount\s*due|'
    r'bill\s*total|total)\b',
    caseSensitive: false,
  );

  /// Rows that look like items but are not.
  static final _notAnItem = RegExp(
    r'\b(sub\s*total|total|cash|change|balance|tendered|card|visa|master|'
    r'tax|vat|svat|service\s*charge|discount|savings?|you\s*saved|'
    r'tel|phone|fax|invoice|bill\s*no|receipt\s*no|cashier|counter|'
    r'date|time|qty|price|amount|thank|welcome|items?\s*count|'
    r'no\s*of\s*items|points|nexus|loyalty|round)\b',
    caseSensitive: false,
  );

  static final _dateFormats = [
    // 23/11/2026, 23-11-26, 23.11.2026 (day first, as printed in Sri Lanka)
    RegExp(r'\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})\b'),
    // 2026-11-23
    RegExp(r'\b(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})\b'),
  ];

  static ParsedReceipt parse(List<String> rows) {
    final lines = [
      for (final r in rows)
        if (r.trim().isNotEmpty) r.replaceAll(RegExp(r'\s+'), ' ').trim(),
    ];

    final totalIndex = _findTotalIndex(lines);
    final itemLines = totalIndex == null ? lines : lines.sublist(0, totalIndex);

    return ParsedReceipt(
      storeName: _findStore(lines),
      date: _findDate(lines),
      totalCents: totalIndex == null ? null : _totalAt(lines, totalIndex),
      items: _findItems(itemLines),
    );
  }

  static String? _findStore(List<String> lines) {
    final top = lines.take(6).toList();
    for (final line in top) {
      final lower = line.toLowerCase();
      for (final entry in _knownStores.entries) {
        if (lower.contains(entry.key)) return entry.value;
      }
    }
    // Otherwise the first line that is mostly letters (the shop's name).
    for (final line in top) {
      final letters = line.replaceAll(RegExp(r'[^A-Za-z]'), '').length;
      if (letters >= 3 &&
          letters >= line.length * 0.6 &&
          !_notAnItem.hasMatch(line)) {
        return _titleCase(line);
      }
    }
    return null;
  }

  static DateTime? _findDate(List<String> lines) {
    for (final line in lines) {
      for (final (i, format) in _dateFormats.indexed) {
        final m = format.firstMatch(line);
        if (m == null) continue;
        final a = int.parse(m.group(1)!);
        final b = int.parse(m.group(2)!);
        final c = int.parse(m.group(3)!);
        final (year, month, day) = i == 0
            ? (c < 100 ? 2000 + c : c, b, a)
            : (a, b, c);
        if (month < 1 || month > 12 || day < 1 || day > 31) continue;
        if (year < 2000 || year > 2100) continue;
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  /// The last "TOTAL" row that is not a sub total.
  static int? _findTotalIndex(List<String> lines) {
    int? found;
    for (var i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (!_totalLine.hasMatch(lower)) continue;
      if (RegExp(r'sub\s*total').hasMatch(lower)) continue;
      if (RegExp(r'items?|qty|savings?').hasMatch(lower)) continue;
      found ??= i;
      // Prefer "net total" / "grand total" when the bill has both.
      if (RegExp(r'net|grand|due').hasMatch(lower)) return i;
    }
    return found;
  }

  /// The amount on the total row, or on the next row if it wrapped.
  static Cents? _totalAt(List<String> lines, int index) {
    for (final line in [
      lines[index],
      if (index + 1 < lines.length) lines[index + 1],
    ]) {
      final amounts = _money.allMatches(line).toList();
      if (amounts.isNotEmpty) return parseRs(amounts.last.group(0)!);
    }
    return null;
  }

  static List<ParsedItem> _findItems(List<String> lines) {
    final items = <ParsedItem>[];
    String? pendingName;

    for (final line in lines) {
      if (_notAnItem.hasMatch(line) || _findDate([line]) != null) {
        pendingName = null;
        continue;
      }
      final amounts = _money.allMatches(line).toList();
      final hasLetters = RegExp(r'[A-Za-z]{2,}').hasMatch(line);

      if (amounts.isEmpty) {
        // A name on its own row; its price may be on the next row.
        pendingName = hasLetters ? line : null;
        continue;
      }

      final last = amounts.last;
      if (last.group(0)!.startsWith('-')) {
        pendingName = null;
        continue; // discounts are left for the user to handle
      }
      final cents = parseRs(last.group(0)!);
      if (cents == null || cents == 0) continue;

      String? name;
      if (hasLetters) {
        name = _cleanName(line.substring(0, amounts.first.start));
      } else if (pendingName != null) {
        // "1.000 x 450.00   450.00" under its name row.
        name = _cleanName(pendingName);
      }
      pendingName = null;
      if (name == null || name.isEmpty) continue;
      items.add(ParsedItem(name, cents));
    }
    return items;
  }

  /// Removes item codes, quantities and stray symbols around a name.
  static String _cleanName(String raw) {
    var name = raw
        // leading item/barcode numbers: "001 ", "4792081011234 "
        .replaceFirst(RegExp(r'^\s*\d{2,}\s+'), '')
        // trailing quantity like "2 x" or "1.000 @"
        .replaceFirst(
          RegExp(r'\s+\d+(?:\.\d+)?\s*[x@*]\s*$', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'[|*#_=]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // Drop a lone trailing number (a quantity) left after cleaning.
    name = name.replaceFirst(RegExp(r'\s+\d+(?:\.\d+)?$'), '').trim();
    return _titleCase(name);
  }

  /// "KEELLS SAMBA RICE" -> "Keells Samba Rice"; mixed case is left alone.
  static String _titleCase(String text) {
    if (text != text.toUpperCase()) return text;
    return text
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
