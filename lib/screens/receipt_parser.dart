class ParsedReceipt {
  final String itemName;
  final double? price;

  ParsedReceipt({required this.itemName, required this.price});
}

class ParsedSize {
  final double amount;
  final String unit;

  ParsedSize(this.amount, this.unit);
}

class ReceiptParser {
  static const List<String> sizeUnits = ['oz', 'lb', 'g', 'kg', 'ml', 'l'];

  static ParsedReceipt parse(String rawText) {
    final cleanText = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();

    double? foundPrice;

    final explicitPriceRegExp = RegExp(r'[\$S]\s?(\d{1,4})[., ]?(\d{2})\b');
    final explicitMatch = explicitPriceRegExp.firstMatch(cleanText);

    if (explicitMatch != null) {
      foundPrice = double.tryParse("${explicitMatch.group(1)}.${explicitMatch.group(2)}");
    } else {
      final decimalRegExp = RegExp(r'\b(\d{1,4})[.,](\d{2})\b');
      final decimalMatch = decimalRegExp.firstMatch(cleanText);
      if (decimalMatch != null) {
        foundPrice = double.tryParse("${decimalMatch.group(1)}.${decimalMatch.group(2)}");
      }
    }

    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    String nameGuess = "Scanned Item";

    for (final line in lines) {
      final isJustNumber = RegExp(r'^[\d\.\$\sS]+$').hasMatch(line);
      final isStopWord = RegExp(
        r'\b(total|tax|cash|change|visa|mastercard|subtotal|unt|unit|per|oz)\b',
        caseSensitive: false,
      ).hasMatch(line);

      if (!isJustNumber && !isStopWord && line.length > 3) {
        nameGuess = line.replaceAll(RegExp(r'[^a-zA-Z0-9\s\-\%]'), '').trim();
        break;
      }
    }

    return ParsedReceipt(itemName: nameGuess, price: foundPrice);
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