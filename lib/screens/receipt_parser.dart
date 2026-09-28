class ParsedReceipt {
  final String itemName;
  final double? price;

  ParsedReceipt({required this.itemName, required this.price});
}

class ReceiptParser {
  static ParsedReceipt parse(String rawText) {
    final cleanText = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();

    double? foundPrice;
    
    // look for explicitly tagged prices or ML Kit typos
    final explicitPriceRegExp = RegExp(r'[\$S]\s?(\d{1,4})[., ]?(\d{2})\b');
    final explicitMatch = explicitPriceRegExp.firstMatch(cleanText);
    
    if (explicitMatch != null) {
      foundPrice = double.tryParse("${explicitMatch.group(1)}.${explicitMatch.group(2)}");
    } else {
      // look for standard decimals if no $ or S is present.

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
      final isStopWord = RegExp(r'\b(total|tax|cash|change|visa|mastercard|subtotal|unt|unit|per|oz)\b', caseSensitive: false).hasMatch(line);

     
      if (!isJustNumber && !isStopWord && line.length > 3) {
        nameGuess = line.replaceAll(RegExp(r'[^a-zA-Z0-9\s\-\%]'), '').trim();
        break; 
      }
    }

    return ParsedReceipt(itemName: nameGuess, price: foundPrice);
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