import 'package:intl/intl.dart';

/// Extension methods on [num] to format numbers and currency in Indonesian.
extension IndonesianCurrency on num {
  /// Formats the number as Indonesian Rupiah (e.g., Rp60.000,00).
  ///
  /// Set `withDecimal` to `false` to drop the decimal places.
  String toRupiah({bool withDecimal = false}) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: withDecimal ? 2 : 0,
    );
    return fmt.format(this);
  }

  /// Formats the number with a 'K' suffix for thousands (e.g., 6,5K, 100K).
  ///
  /// This is useful for displaying large numbers in a concise format.
  String toK() {
    if (this >= 1000) {
      final value = this / 1000;
      // Using 'id_ID' locale to ensure correct decimal (comma) and thousand (dot) separators.
      final fmt = NumberFormat('0.##', 'id_ID');
      return '${fmt.format(value)}K';
    }
    return toString();
  }

  /// Formats the number into a short, informal Rupiah format (e.g., Rp 60rb).
  ///
  /// This is commonly used in user interfaces for better readability.
  String toShortRupiah() {
    if (this >= 1000000) {
      final value = this / 1000000;
      return 'Rp ${NumberFormat('0.#').format(value)}jt';
    } else if (this >= 1000) {
      final value = this / 1000;
      return 'Rp ${NumberFormat('0.#').format(value)}rb';
    }
    return 'Rp ${NumberFormat.decimalPattern('id_ID').format(this)}';
  }

  /// A more general currency formatter that can handle various symbols.
  ///
  /// [symbol]: The currency symbol to use (e.g., '€', '$'). Defaults to 'Rp'.
  /// [withDecimal]: Whether to include decimal places.
  String toCurrency({String symbol = 'Rp', bool withDecimal = true}) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '$symbol ',
      decimalDigits: withDecimal ? 2 : 0,
    );
    return fmt.format(this);
  }

  /// Formats the number with thousand separators based on a specified locale.
  ///
  /// For Indonesian (`id_ID`), this results in a period as the separator (e.g., "1.000").
  /// For US English (`en_US`), this results in a comma as the separator (e.g., "1,000").
  String toFormattedString({String locale = 'id_ID'}) {
    final fmt = NumberFormat.decimalPattern(locale);
    return fmt.format(this);
  }
}

// A simple main function to demonstrate the usage.
void main() {
  // final price1 = 50000;
  // final price2 = 1250000;
  // final price3 = 999;
  // final price4 = 1500;
  // final price5 = 2500000;
  // final price6 = 123456789;

  // print('toRupiah:');
  // print('  Rp $price1 -> ${price1.toRupiah()}');
  // print('  Rp $price2 -> ${price2.toRupiah()}');

  // print('\ntoK:');
  // print('  $price3 -> ${price3.toK()}');
  // print('  $price4 -> ${price4.toK()}');
  // print('  $price5 -> ${price5.toK()}');
  // print('  $price6 -> ${price6.toK()}');

  // print('\ntoShortRupiah:');
  // print('  $price1 -> ${price1.toShortRupiah()}');
  // print('  $price2 -> ${price2.toShortRupiah()}');
  // print('  $price3 -> ${price3.toShortRupiah()}');
  // print('  $price5 -> ${price5.toShortRupiah()}');
  // print('  $price6 -> ${price6.toShortRupiah()}');

  // print('\ntoCurrency:');
  // print('  $price1 -> ${price1.toCurrency(symbol: '\$')}');
  // print('  $price2 -> ${price2.toCurrency(symbol: '€')}');

  // print('\ntoFormattedString:');
  // print('  1500 (ID) -> ${1500.toFormattedString()}');
  // print('  1500 (US) -> ${1500.toFormattedString(locale: 'en_US')}');
  // print('  1250000 (ID) -> ${1250000.toFormattedString()}');
  // print('  1250000 (US) -> ${1250000.toFormattedString(locale: 'en_US')}');
}
