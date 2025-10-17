import 'package:flutter_core/src/core/domain/failures/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for error and stackTrace if needed
class MockError extends Mock implements Exception {}

class MockStackTrace extends Mock implements StackTrace {}

void main() {
  group('Failure Hierarchy', () {
    const message = 'Test failure';
    final error = MockError();
    final stackTrace = MockStackTrace();
    const statusCode = 500;
    const errors = {'field': 'Invalid input'};

    test('ServerFailure initializes correctly', () {
      final failure = ServerFailure(
        message: message,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure.message, message);
      expect(failure.error, error);
      expect(failure.stackTrace, stackTrace);
      expect(failure.statusCode, statusCode);
      expect(failure.toString(),
          'ServerFailure(message: $message, error: $error, statusCode: $statusCode)');
    });

    test('ServerFailure equality and hashCode', () {
      final failure1 = ServerFailure(
        message: message,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );
      final failure2 = ServerFailure(
        message: message,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );
      final failure3 = ServerFailure(
        message: 'Different',
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure1, equals(failure2));
      expect(failure1.hashCode, failure2.hashCode);
      expect(failure1, isNot(failure3));
      expect(failure1.hashCode, isNot(failure3.hashCode));
      expect(failure1.props, [message, error, stackTrace, statusCode]);
    });

    test('NetworkFailure initializes correctly', () {
      final failure = NetworkFailure(
        message: message,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure.message, message);
      expect(failure.error, error);
      expect(failure.stackTrace, stackTrace);
      expect(failure.statusCode, statusCode);
      expect(failure.toString(),
          'NetworkFailure(message: $message, error: $error, statusCode: $statusCode)');
    });

    test('CacheFailure initializes correctly', () {
      final failure = CacheFailure(
        message: message,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure.message, message);
      expect(failure.error, error);
      expect(failure.stackTrace, stackTrace);
      expect(failure.statusCode, statusCode);
      expect(failure.toString(),
          'CacheFailure(message: $message, error: $error, statusCode: $statusCode)');
    });

    test('AuthFailure initializes correctly', () {
      final failure = AuthFailure(
        message: message,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure.message, message);
      expect(failure.error, error);
      expect(failure.stackTrace, stackTrace);
      expect(failure.statusCode, statusCode);
      expect(failure.toString(),
          'AuthFailure(message: $message, error: $error, statusCode: $statusCode)');
    });

    test('ValidationFailure initializes correctly', () {
      final failure = ValidationFailure(
        errors: errors,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure.message, 'One or more validation errors occurred.');
      expect(failure.errors, errors);
      expect(failure.error, error);
      expect(failure.stackTrace, stackTrace);
      expect(failure.statusCode, statusCode);
      expect(failure.toString(),
          'ValidationFailure(message: One or more validation errors occurred., error: $error, statusCode: $statusCode)');
      expect(failure.props, [
        'One or more validation errors occurred.',
        error,
        stackTrace,
        statusCode,
        errors
      ]);
    });

    test('ValidationFailure equality and hashCode', () {
      final failure1 = ValidationFailure(
        errors: errors,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );
      final failure2 = ValidationFailure(
        errors: errors,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );
      final failure3 = ValidationFailure(
        errors: const {'different': 'error'},
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure1, equals(failure2));
      expect(failure1.hashCode, failure2.hashCode);
      expect(failure1, isNot(failure3));
      expect(failure1.hashCode, isNot(failure3.hashCode));
    });

    test('GenericFailure initializes correctly', () {
      final failure = GenericFailure(
        message: message,
        error: error,
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      expect(failure.message, message);
      expect(failure.error, error);
      expect(failure.stackTrace, stackTrace);
      expect(failure.statusCode, statusCode);
      expect(failure.toString(),
          'GenericFailure(message: $message, error: $error, statusCode: $statusCode)');
    });
  });

  group('Result Type', () {
    const data = 'Test data';
    const failure = GenericFailure(message: 'Test failure', statusCode: 500);

    test('Success initializes correctly', () {
      const result = Success<String, Failure>(data);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, data);
      expect(result.failure, isNull);
    });

    test('Error initializes correctly', () {
      const result = Error<String, Failure>(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.data, isNull);
      expect(result.failure, failure);
    });
  });

  group('ResultExtension', () {
    const data = 'Test data';
    const failure = GenericFailure(message: 'Test failure', statusCode: 500);

    test('isSuccess and isFailure getters for Success', () {
      const result = Success<String, Failure>(data);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('isSuccess and isFailure getters for Error', () {
      const result = Error<String, Failure>(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('requiredData returns data for Success', () {
      const result = Success<String, Failure>(data);

      expect(result.requiredData, data);
    });

    test('requiredData throws StateError for Error', () {
      const result = Error<String, Failure>(failure);

      expect(
        () => result.requiredData,
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Cannot access data from a failed result'),
        )),
      );
    });

    test('when handles Success case', () {
      const result = Success<String, Failure>(data);

      final output = result.when(
        onSuccess: (value) => 'Success: $value',
        onFailure: (f) => 'Failure: ${f.message}',
      );

      expect(output, 'Success: $data');
    });

    test('when handles Error case', () {
      const result = Error<String, Failure>(failure);

      final output = result.when(
        onSuccess: (value) => 'Success: $value',
        onFailure: (f) => 'Failure: ${f.message}',
      );

      expect(output, 'Failure: ${failure.message}');
    });

    test('when throws if onSuccess or onFailure is not provided', () {
      const result = Success<String, Failure>(data);

      expect(
        () => result.when(
          onSuccess: (value) => 'Success: $value',
          onFailure: (null as dynamic), // Simulate missing onFailure
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
