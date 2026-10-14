import 'package:flutter/foundation.dart';
import 'app_drawer.dart';
class CompareEntry {
  final String name;
  final double price;
  final double? sizeOz;
  final String? sizeLabel;

  CompareEntry({
    required this.name,
    required this.price,
    this.sizeOz,
    this.sizeLabel,
  });

  double? get pricePerOz =>
      (sizeOz != null && sizeOz! > 0) ? price / sizeOz! : null;
}

class CompareManager {
  CompareManager._internal();
  static final CompareManager instance = CompareManager._internal();

  final ValueNotifier<List<CompareEntry>> entries =
      ValueNotifier<List<CompareEntry>>([]);

  void add(CompareEntry entry) {
    entries.value = [...entries.value, entry];
  }

  void removeAt(int index) {
    final updated = [...entries.value]..removeAt(index);
    entries.value = updated;
  }

  void clear() {
    entries.value = [];
  }
}