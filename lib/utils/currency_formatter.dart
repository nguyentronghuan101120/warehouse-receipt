import 'package:intl/intl.dart';

extension NumExtension on num {
  String toVND() {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return formatter.format(this);
  }

  String toVNDWithDecimal() {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 2,
    );

    return formatter.format(this);
  }
}
