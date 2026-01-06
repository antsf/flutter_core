// lib/src/date_ext.dart
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Extension methods for [DateTime] to format dates and times in Indonesian.
extension IndonesianDate on DateTime {
  /// Initializes the date formatting for the Indonesian locale.
  static void initialize() {
    initializeDateFormatting('id_ID', null);
  }

  /// Formats the date to a short Indonesian format (e.g., `26/06/2025`).
  String toShortIndonesianDate() {
    initialize();
    return DateFormat('dd/MM/yyyy', 'id_ID').format(this);
  }

  /// Formats the date with a short month name (e.g., `26 Jun 2025`).
  String toShortMonthName() {
    initialize();
    return DateFormat('d MMM yyyy', 'id_ID').format(this);
  }

  /// Formats the date with a full month name (e.g., `26 Juni 2025`).
  String toIndonesianDate() {
    initialize();
    return DateFormat('d MMMM yyyy', 'id_ID').format(this);
  }

  /// Formats the date with the full day of the week (e.g., `Kamis, 26 Juni 2025`).
  String toIndonesianDateWithDay() {
    initialize();
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(this);
  }

  /// Formats the date with the full day of the week and time (e.g., `Kamis, 26 Juni 2025 14:30`).
  String toIndonesianDateTime() {
    initialize();
    return DateFormat('EEEE, d MMMM yyyy HH:mm', 'id_ID').format(this);
  }

  /// Formats the date with the full day of the week and time (e.g., `Kamis, 26 Jun 2025 14:30`).
  String toIndonesiandMMMyyyy() {
    initialize();
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(this);
  }

  /// Formats the date with full month name and time (e.g., `26 Juni 2025 14:30`).
  String toDateTime() {
    initialize();
    return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(this);
  }

  /// Formats the date with full month name and time (e.g., `26 Juni 2025 14:30:00`).
  String toDateTimeWithSeconds() {
    initialize();
    return DateFormat('d MMMM yyyy HH:mm:ss', 'id_ID').format(this);
  }

  /// Formats the date with short month name and time (e.g., `26 Jun 2025 14:30`).
  String toShortDateTime() {
    initialize();
    return DateFormat('d MMM yyyy HH:mm', 'id_ID').format(this);
  }

  /// Formats to a short date and time (e.g., `26/06/2025 14:30`).
  String toShortDateWithTime() {
    initialize();
    return DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(this);
  }

  /// Formats the time to `dd/MM` (e.g., `26/06`).
  String toDayAndMonth() {
    initialize();
    return DateFormat('dd/MM', 'id_ID').format(this);
  }

  /// Formats the time to `HH:mm` (e.g., `14:30`).
  String toTime() {
    initialize();
    return DateFormat('HH:mm', 'id_ID').format(this);
  }

  /// Formats the time to `HH:mm:ss` (e.g., `14:30:45`).
  String toTimeWithSeconds() {
    initialize();
    return DateFormat('HH:mm:ss', 'id_ID').format(this);
  }

  /// Formats the date for a database (e.g., `2025-06-26`).
  String toDbFormat() {
    initialize();
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Formats the full date and time for a database (e.g., `2025-06-26 14:30:45`).
  String toDbDateTimeFormat() {
    initialize();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }
}
