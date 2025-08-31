import 'package:intl/intl.dart';

String formatCurrency(int price) {
  final formatter = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  return formatter.format(price);
}
