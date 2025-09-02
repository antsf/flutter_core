// lib/src/number_ext.dart
import 'package:intl/intl.dart';

extension IndonesianCurrency on num {
  /// Rp60.000,00  (you can drop decimals via `symbol: ''`)
  String toRupiah({bool withDecimal = true}) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: withDecimal ? 2 : 0,
    );
    return fmt.format(this);
  }
}
