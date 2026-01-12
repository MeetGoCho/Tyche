import 'package:intl/intl.dart';

extension NumExtension on num {
  String toCurrency({String symbol = '\$', int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  String toCompactCurrency({String symbol = '\$'}) {
    final formatter = NumberFormat.compactCurrency(symbol: symbol);
    return formatter.format(this);
  }

  String toPercent({int decimalDigits = 2}) {
    return '${toStringAsFixed(decimalDigits)}%';
  }

  String toCompact() {
    final formatter = NumberFormat.compact();
    return formatter.format(this);
  }

  String toDecimal({int decimalDigits = 2}) {
    return toStringAsFixed(decimalDigits);
  }
}
