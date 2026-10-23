import 'package:flutter/services.dart';

/// Allows only positive decimal numbers at input level: digits, a single
/// dot, and a capped fraction length. Minus signs, extra dots and
/// over-long fractions are rejected (previous value is kept).
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalDigits = 2});

  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;
    if (decimalDigits >= 0 && text.contains('.')) {
      final fraction = text.split('.').last;
      if (fraction.length > decimalDigits) return oldValue;
    }
    return newValue;
  }
}
