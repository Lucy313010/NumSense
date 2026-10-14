class ParsedReceipt {
  final String itemName;
  final double? price;
  final bool priceInferred;

  ParsedReceipt({
    required this.itemName,
    required this.price,
    this.priceInferred = false,
  });
}

class ParsedSize {
  final double amount;
  final String unit;

  ParsedSize(this.amount, this.unit);
}

class TextLineInfo {
  final String text;
  final double height;

  TextLineInfo(this.text, this.height);
}

class ReceiptParser {
  static const List<String> sizeUnits = ['oz', 'lb', 'g', 'kg', 'ml', 'l'];

  static final RegExp _discountKeywords = RegExp(
    r'\b(was|reg|regular|orig|original|compare\s*at|list\s*price|msrp)\b',
    caseSensitive: false,
  );

  static final RegExp _ignoreNameKeywords = RegExp(
    r'\b(retail|price|unit|was|dropped|everyday|low|save|special|rollback|fac|cap|srp|per|each|oz|lb)\b',
    caseSensitive: false,
  );

  static final RegExp _decimalPriceRegExp = RegExp(r'[\$Ss]?\s?(\d{1,3})[.,](\d{2})\b');

  static final RegExp _noDecimalPriceRegExp = RegExp(r'[\$Ss]\s?(\d{3,4})(?!\d)');

  static ParsedReceipt parse(String rawText, {List<TextLineInfo>? lines}) {
    final workingLines = (lines != null && lines.isNotEmpty)
        ? [for (final l in lines) _Line(l.text.trim(), l.height)]
            .where((l) => l.text.isNotEmpty)
            .toList()
        : [
            for (final t in rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty))
              _Line(t, 1.0),
          ];

    final priceResult = _guessPrice(workingLines);

    return ParsedReceipt(
      itemName: _guessName(workingLines),
      price: priceResult?.value,
      priceInferred: priceResult?.inferred ?? false,
    );
  }

  static String _guessName(List<_Line> lines) {
    for (final line in lines) {
      final isPureNumbers = RegExp(r'^[\d\.\$\sS\-/,]+$').hasMatch(line.text);
      final hasIgnoreWord = _ignoreNameKeywords.hasMatch(line.text);
      final isDiscountLine = _discountKeywords.hasMatch(line.text);

      if (!isPureNumbers && !hasIgnoreWord && !isDiscountLine && line.text.length >= 3) {
        final cleaned = line.text
            .replaceAll(RegExp(r'[^a-zA-Z0-9\s\-\%]'), '')
            .replaceAll(RegExp(r'\s+[sS]{1,2}$'), '')
            .trim();
        if (cleaned.length >= 3) return cleaned;
      }
    }
    return "Scanned Item";
  }

  static _PriceCandidate? _guessPrice(List<_Line> lines) {
    final candidates = <_PriceCandidate>[];

    for (final line in lines) {
      final isDiscountLine = _discountKeywords.hasMatch(line.text);

      final decimalMatch = _decimalPriceRegExp.firstMatch(line.text);
      if (decimalMatch != null) {
        final value = double.tryParse('${decimalMatch.group(1)}.${decimalMatch.group(2)}');
        if (value != null && value > 0 && value < 500) {
          candidates.add(_PriceCandidate(value, line.height, inferred: false, isDiscount: isDiscountLine));
          continue;
        }
      }

      final noDecimalMatch = _noDecimalPriceRegExp.firstMatch(line.text);
      if (noDecimalMatch != null) {
        final digits = noDecimalMatch.group(1)!;
        final dollars = digits.substring(0, digits.length - 2);
        final cents = digits.substring(digits.length - 2);
        final value = double.tryParse('$dollars.$cents');
        if (value != null && value > 0 && value < 500) {
          candidates.add(_PriceCandidate(value, line.height, inferred: true, isDiscount: isDiscountLine));
        }
      }
    }

    if (candidates.isEmpty) return null;

    final preferred = candidates.where((c) => !c.isDiscount).toList();
    final pool = preferred.isNotEmpty ? preferred : candidates;


    pool.sort((a, b) {
      if (a.inferred != b.inferred) return a.inferred ? 1 : -1;
      return b.height.compareTo(a.height);
    });

    return pool.first;
  }

  static ParsedSize? parseSize(String rawText) {
    final match = RegExp(
      r'(\d{1,4}(?:\.\d{1,2})?)\s*(fl\.?\s*oz|oz|lbs?|kg|ml|g|l)\b',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (match == null) return null;

    final amount = double.tryParse(match.group(1)!);
    if (amount == null || amount <= 0) return null;

    final raw = match.group(2)!.toLowerCase().replaceAll(RegExp(r'[\s.]'), '');
    final unit = raw == 'floz' ? 'oz' : (raw == 'lbs' ? 'lb' : raw);
    return ParsedSize(amount, unit);
  }

  static double toOunces(double amount, String unit) {
    switch (unit) {
      case 'lb':
        return amount * 16;
      case 'g':
        return amount * 0.035274;
      case 'kg':
        return amount * 35.274;
      case 'ml':
        return amount * 0.033814;
      case 'l':
        return amount * 33.814;
      default:
        return amount;
    }
  }

  static double? parseWeight(String rawText) {
    final weightRegExp = RegExp(r'(\d{1,3}(?:\.\d{1,3})?)\s*(lb|lbs|oz|kg|g)\b', caseSensitive: false);
    final match = weightRegExp.firstMatch(rawText);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    final fallbackMatches = RegExp(r'(\d{1,3}\.\d{1,3})').allMatches(rawText);
    for (final fallback in fallbackMatches) {
      final val = double.tryParse(fallback.group(1)!);
      if (val != null) return val;
    }
    return null;
  }

  static String formatRawTextForUI(String rawText) {
    return rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n');
  }
}

class _Line {
  final String text;
  final double height;
  _Line(this.text, this.height);
}

class _PriceCandidate {
  final double value;
  final double height;
  final bool inferred;
  final bool isDiscount;
  _PriceCandidate(this.value, this.height, {required this.inferred, required this.isDiscount});
}