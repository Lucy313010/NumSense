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
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    double? foundPrice;
    String nameGuess = "Scanned Item";

    // 1. Identify Item Name (Skip promo titles, prices, and system codes)
    final ignoreKeywords = RegExp(
      r'\b(retail|price|unit|was|dropped|everyday|low|save|special|rollback|fac|cap|srp|per|each|oz|lb)\b',
      caseSensitive: false,
    );

    for (final line in lines) {
      final isPureNumbers = RegExp(r'^[\d\.\$\sS\-/,]+$').hasMatch(line);
      final hasIgnoreWord = ignoreKeywords.hasMatch(line);

      if (!isPureNumbers && !hasIgnoreWord && line.length >= 3) {
        String cleanLine = line
            .replaceAll(RegExp(r'[^a-zA-Z0-9\s\-\%]'), '')
            .replaceAll(RegExp(r'\s+[sS]{1,2}$'), '')
            .trim();

        if (cleanLine.length >= 3) {
          nameGuess = cleanLine;
          break;
        }
      }
    }

    // 2. Identify Price
    // Regex matches explicit prices with decimals like $4.98 or $32.99
    final decimalPriceRegExp = RegExp(r'[\$S]?\s?(\d{1,3})[\.,](\d{2})\b');
    
    for (final line in lines) {
      // Prioritize explicit price lines
      final match = decimalPriceRegExp.firstMatch(line);
      if (match != null) {
        final dollars = match.group(1)!;
        final cents = match.group(2)!;
        final candidate = double.tryParse("$dollars.$cents");
        
        // Exclude unit prices per oz/lb if main price exists
        if (candidate != null && candidate > 0 && candidate < 500) {
          foundPrice = candidate;
          break;
        }
      }
    }

    // Fallback: If price came in as $498 without decimal, convert to 4.98 if > 99
    if (foundPrice == null) {
      final wholeDollarRegExp = RegExp(r'[\$S]\s?(\d{3,4})\b');
      final match = wholeDollarRegExp.firstMatch(rawText);
      if (match != null) {
        final val = double.tryParse(match.group(1)!);
        if (val != null) {
          foundPrice = val / 100.0; // 498 -> 4.98
        }
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