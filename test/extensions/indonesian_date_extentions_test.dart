import 'package:flutter_core/src/extensions/date_ext.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// EXTENSION UNDER TEST (copied from user input for self-containment)
// -----------------------------------------------------------------------------

// /// Extension methods for [DateTime] to format dates and times in Indonesian.
// extension IndonesianDate on DateTime {
//   /// Initializes the date formatting for the Indonesian locale.
//   static void initialize() {
//     // Note: In a real app, this should only be called once,
//     // usually in the main function or bootstrap code.
//     initializeDateFormatting('id_ID', null);
//   }

//   /// Formats the date to a short Indonesian format (e.g., `26/06/2025`).
//   String toShortIndonesianDate() {
//     initialize();
//     return DateFormat('dd/MM/yyyy', 'id_ID').format(this);
//   }

//   /// Formats the date with a short month name (e.g., `26 Jun 2025`).
//   String toShortMonthName() {
//     initialize();
//     return DateFormat('d MMM yyyy', 'id_ID').format(this);
//   }

//   /// Formats the date with a full month name (e.g., `26 Juni 2025`).
//   String toIndonesianDate() {
//     initialize();
//     return DateFormat('d MMMM yyyy', 'id_ID').format(this);
//   }

//   /// Formats the date with the full day of the week (e.g., `Kamis, 26 Juni 2025`).
//   String toIndonesianDateWithDay() {
//     initialize();
//     return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(this);
//   }

//   /// Formats the date with the full day of the week and time (e.g., `Kamis, 26 Juni 2025 14:30`).
//   String toIndonesianDateTime() {
//     initialize();
//     return DateFormat('EEEE, d MMMM yyyy HH:mm', 'id_ID').format(this);
//   }

//   /// Formats the date with full month name and time (e.g., `26 Juni 2025 14:30`).
//   String toDateTime() {
//     initialize();
//     return DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(this);
//   }

//   /// Formats the date with short month name and time (e.g., `26 Jun 2025 14:30`).
//   String toShortDateTime() {
//     initialize();
//     return DateFormat('d MMM yyyy HH:mm', 'id_ID').format(this);
//   }

//   /// Formats to a short date and time (e.g., `26/06/2025 14:30`).
//   String toShortDateWithTime() {
//     initialize();
//     return DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(this);
//   }

//   /// Formats the time to `dd/MM` (e.g., `26/06`).
//   String toDayAndMonth() {
//     initialize();
//     return DateFormat('dd/MM', 'id_ID').format(this);
//   }

//   /// Formats the time to `HH:mm` (e.g., `14:30`).
//   String toTime() {
//     initialize();
//     return DateFormat('HH:mm', 'id_ID').format(this);
//   }

//   /// Formats the time to `HH:mm:ss` (e.g., `14:30:45`).
//   String toTimeWithSeconds() {
//     initialize();
//     return DateFormat('HH:mm:ss', 'id_ID').format(this);
//   }

//   /// Formats the date for a database (e.g., `2025-06-26`).
//   String toDbFormat() {
//     initialize();
//     return DateFormat('yyyy-MM-dd').format(this);
//   }

//   /// Formats the full date and time for a database (e.g., `2025-06-26 14:30:45`).
//   String toDbDateTimeFormat() {
//     initialize();
//     return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
//   }
// }

// -----------------------------------------------------------------------------
// UNIT TESTS
// -----------------------------------------------------------------------------

void main() {
  // A consistent test date (Thursday, June 26, 2025, 14:30:45)
  final testDate = DateTime(2025, 6, 26, 14, 30, 45);

  // Initialize the Indonesian locale once for all tests.
  // This is crucial for the intl package to resolve localized names (like 'Kamis').
  setUpAll(() {
    IndonesianDate.initialize();
  });

  group('IndonesianDate Extension Tests', () {
    // --- Short/Numeric Formats ---

    test('toShortIndonesianDate formats to dd/MM/yyyy', () {
      expect(testDate.toShortIndonesianDate(), '26/06/2025');
    });

    test('toDayAndMonth formats to dd/MM', () {
      expect(testDate.toDayAndMonth(), '26/06');
    });

    // --- Full Date Formats (Indonesian Locale Specific) ---

    test('toIndonesianDate formats to d MMMM yyyy (full month)', () {
      expect(testDate.toIndonesianDate(), '26 Juni 2025');
    });

    test('toShortMonthName formats to d MMM yyyy (short month)', () {
      expect(testDate.toShortMonthName(), '26 Jun 2025');
    });

    test('toIndonesianDateWithDay formats to EEEE, d MMMM yyyy', () {
      // June 26, 2025 is a Thursday, which is "Kamis" in Indonesian.
      expect(testDate.toIndonesianDateWithDay(), 'Kamis, 26 Juni 2025');
    });

    // --- Time Formats ---

    test('toTime formats to HH:mm', () {
      expect(testDate.toTime(), '14:30');
    });

    test('toTimeWithSeconds formats to HH:mm:ss', () {
      expect(testDate.toTimeWithSeconds(), '14:30:45');
    });

    // --- Date and Time Combinations ---

    test('toShortDateWithTime formats to dd/MM/yyyy HH:mm', () {
      expect(testDate.toShortDateWithTime(), '26/06/2025 14:30');
    });

    test('toDateTime formats to d MMMM yyyy HH:mm', () {
      expect(testDate.toDateTime(), '26 Juni 2025 14:30');
    });

    test('toShortDateTime formats to d MMM yyyy HH:mm', () {
      expect(testDate.toShortDateTime(), '26 Jun 2025 14:30');
    });

    test('toIndonesianDateTime formats to EEEE, d MMMM yyyy HH:mm', () {
      expect(testDate.toIndonesianDateTime(), 'Kamis, 26 Juni 2025 14:30');
    });

    // --- Database Formats (ISO-like) ---

    test('toDbFormat formats to yyyy-MM-dd', () {
      expect(testDate.toDbFormat(), '2025-06-26');
    });

    test('toDbDateTimeFormat formats to yyyy-MM-dd HH:mm:ss', () {
      expect(testDate.toDbDateTimeFormat(), '2025-06-26 14:30:45');
    });
  });
}
