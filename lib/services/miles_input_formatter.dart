import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MilesInputFormatter extends TextInputFormatter {
  final NumberFormat format;

  MilesInputFormatter(this.format);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(',', '');

    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final formatted = format.format(int.parse(digits));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}
