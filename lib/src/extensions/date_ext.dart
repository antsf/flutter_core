// lib/src/date_ext.dart
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

extension IndonesianDate on DateTime {
  /// e.g. 26 Juni 2025
  String toIndonesianDate({bool withDay = false}) {
    initializeDateFormatting('id_ID', null);
    final fmt = withDay
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID')
        : DateFormat('d MMMM yyyy', 'id_ID');
    return fmt.format(this);
  }

  /// e.g. Kamis, 26 Juni 2025 14:30
  String toIndonesianDateTime() {
    initializeDateFormatting('id_ID', null);
    return DateFormat('EEEE, d MMMM yyyy HH:mm', 'id_ID').format(this);
  }
}
