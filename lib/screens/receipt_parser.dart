class ParsedReceipt {
  final String itemName;
  final double? price;

  ParsedReceipt({required this.itemName, required this.price});
}

class ReceiptParser {
  static ParsedReceipt parse(String rawText) {
    final priceMatches = RegExp(r'(\d{1,4}\.\d{2})').allMatches(rawText);
    double? bestPrice;
    for (final match in priceMatches) {
      final value = double.tryParse(match.group(1)!);
      if (value != null && (bestPrice == null || value > bestPrice)) {
        bestPrice = value;
      }
    }

    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    String nameGuess = "Scanned Item";
    for (final line in lines) {
      final hasDigit = RegExp(r'\d').hasMatch(line);
      if (!hasDigit && line.length > 2) {
        nameGuess = line;
        break;
      }
    }

    return ParsedReceipt(itemName: nameGuess, price: bestPrice);
  }

  static double? parseWeight(String rawText) {
    final matches = RegExp(r'(\d{1,3}\.\d{1,3})').allMatches(rawText);
    for (final match in matches) {
      final value = double.tryParse(match.group(1)!);
      if (value != null) return value;
    }
    return null;
  }
}