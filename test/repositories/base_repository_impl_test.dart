// test/repositories/base_repository_impl_test.dart
import 'package:flutter_core/flutter_core.dart'; // Import necessary core utilities
import 'package:flutter_core/src/core/data/datasources/base_local_data_source.dart'
    show BaseLocalDataSource;
import 'package:flutter_core/src/core/data/datasources/base_remote_data_source.dart'
    show BaseRemoteDataSource;
import 'package:flutter_core/src/core/data/repositories/data_source_strategy.dart'
    show DataSourceStrategy;
import 'package:flutter_core/src/core/domain/failures/failures.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import '../entities/test_entity.dart';
import '../models/test_model.dart';
import '../repositories/test_repository.dart';
// NOTE: We don't use the mock data sources from the original test file; we define mocks here.

// --- MOCK DEFINITIONS ---
// Use Mocktail to create mocks for the dependencies

// 1. Mock the BaseRemoteDataSource
class MockRemoteDataSource extends Mock
    implements BaseRemoteDataSource<TestModel> {}

// 2. Mock the BaseLocalDataSource
class MockLocalDataSource extends Mock
    implements BaseLocalDataSource<TestEntity> {}

// 3. Mock TestEntity and TestModel for setup
class MockTestEntity extends Mock implements TestEntity {
  @override
  String get id => '1';
}

class MockTestModel extends Mock implements TestModel {
  @override
  String get id => '1';
  @override
  TestEntity toEntity() => const TestEntity(id: '1', name: 'Remote Data');
}

// Helper to simulate a remote failure (ServerException, which should be caught by safeCall)
class TestServerException implements Exception {}

void main() {
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;
  late TestRepository repository;

  // Test data
  const tId = '1';
  const tEntity = TestEntity(id: tId, name: 'Test Entity');
  final tModel = TestModel(id: tId, name: 'Test Entity');
  const tEntityList = [tEntity, TestEntity(id: '2', name: 'B')];
  final tModelList = [tModel, TestModel(id: '2', name: 'B')];

  setUpAll(() {
    // Register fallbacks for un-stubbed methods, required by Mocktail
    registerFallbackValue(tEntity);
    registerFallbackValue(tModel);
    registerFallbackValue(tEntityList);
  });

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();

    // Initialize repository with mocks, defaulting to remoteWithLocalCache strategy
    repository = TestRepository(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      strategy: DataSourceStrategy.remoteWithLocalCache,
    );
  });

  // --------------------------------------------------------------------------

  group('getAll (RemoteWithLocalCache Strategy)', () {
    test('should return remote data and save to cache when remote succeeds',
        () async {
      // ARRANGE
      // 1. Remote setup: Mock remote call to succeed and return models.
      // NOTE: We mock the exception-throwing remoteDataSource.getAll(),
      // the repository's safeCall wrapper handles the try-catch.
      when(() => mockRemoteDataSource.getAll())
          .thenAnswer((_) async => tModelList);

      // 2. Local setup: Mock local save to succeed.
      when(() => mockLocalDataSource.saveAll(any()))
          .thenAnswer((_) async => Future.value());

      // ACT
      final result = await repository.getAll();

      // ASSERT
      expect(result, isA<Success<List<TestEntity>, Failure>>());
      expect(result.data, tEntityList);

      // VERIFY
      verify(() => mockRemoteDataSource.getAll()).called(1);
      // Verify that saveAll was called with the transformed entities.
      verify(() => mockLocalDataSource.saveAll(tEntityList)).called(1);
      verifyNever(() =>
          mockLocalDataSource.getAll()); // Not called in remoteWithLocalCache
    });

    test('should return NetworkFailure when remote call throws an exception',
        () async {
      // ARRANGE
      // Mock remote call to throw an exception (e.g., ServerException, caught by safeCall)
      when(() => mockRemoteDataSource.getAll())
          .thenThrow(TestServerException());

      // ACT
      final result = await repository.getAll();

      // ASSERT
      expect(result, isA<Error<List<TestEntity>, Failure>>());
      expect(result.failure, isA<NetworkFailure>());

      // VERIFY
      verify(() => mockRemoteDataSource.getAll()).called(1);
      verifyNever(() => mockLocalDataSource.saveAll(any()));
    });
  });

  // --------------------------------------------------------------------------

  group('create (Write Operation)', () {
    test('should return Success, call remote.create, and local.save', () async {
      // ARRANGE
      final createdModel = TestModel(id: '99', name: 'New Item');
      final createdEntity = createdModel.toEntity();

      // 1. Remote setup: Mock remote call to succeed and return the created model (with ID).
      when(() => mockRemoteDataSource.create(any()))
          .thenAnswer((_) async => createdModel);

      // 2. Local setup: Mock local save to succeed.
      when(() => mockLocalDataSource.save(any()))
          .thenAnswer((_) async => Future.value());

      // ACT
      final result = await repository.create(createdEntity);

      // ASSERT
      expect(result, isA<Success<TestEntity, Failure>>());
      expect(result.data!.id, '99');

      // VERIFY
      // Verify remote was called with the model created from the input entity
      verify(() => mockRemoteDataSource
          .create(TestModel(id: '99', name: 'New Item'))).called(1);
      // Verify local save was called with the entity returned from the remote source
      verify(() => mockLocalDataSource.save(createdEntity)).called(1);
    });

    test('should return NetworkFailure if remote.create throws', () async {
      // ARRANGE
      when(() => mockRemoteDataSource.create(any()))
          .thenThrow(TestServerException());

      // ACT
      final result = await repository.create(tEntity);

      // ASSERT
      expect(result, isA<Error<TestEntity, Failure>>());
      expect(result.failure, isA<NetworkFailure>());

      // VERIFY
      verify(() => mockRemoteDataSource.create(any())).called(1);
      verifyNever(() => mockLocalDataSource.save(any()));
    });
  });

  // --------------------------------------------------------------------------

  group('delete (Void Operation)', () {
    test('should return Success and call remote.delete and local.delete',
        () async {
      // ARRANGE
      // 1. Remote setup: Mock remote delete to succeed.
      when(() => mockRemoteDataSource.delete(tId))
          .thenAnswer((_) async => Future.value());

      // 2. Local setup: Mock local delete to succeed.
      when(() => mockLocalDataSource.delete(tId))
          .thenAnswer((_) async => Future.value());

      // ACT
      final result = await repository.delete(tId);

      // ASSERT
      expect(result, isA<Success<void, Failure>>());
      expect(result.failure, isNull);

      // VERIFY
      verify(() => mockRemoteDataSource.delete(tId)).called(1);
      verify(() => mockLocalDataSource.delete(tId)).called(1);
    });

    test('should return NetworkFailure if remote.delete throws', () async {
      // ARRANGE
      when(() => mockRemoteDataSource.delete(tId))
          .thenThrow(TestServerException());

      // ACT
      final result = await repository.delete(tId);

      // ASSERT
      expect(result, isA<Error<void, Failure>>());
      expect(result.failure, isA<NetworkFailure>());

      // VERIFY
      verify(() => mockRemoteDataSource.delete(tId)).called(1);
      verifyNever(() => mockLocalDataSource.delete(tId));
    });

    test(
        'should return Success even if local.delete fails after remote success',
        () async {
      // ARRANGE
      // 1. Remote setup: Succeeds
      when(() => mockRemoteDataSource.delete(tId))
          .thenAnswer((_) async => Future.value());

      // 2. Local setup: Fails (the repository handles this with a log and still returns Success)
      when(() => mockLocalDataSource.delete(tId))
          .thenThrow(Exception('Cache error'));

      // ACT
      final result = await repository.delete(tId);

      // ASSERT
      expect(result,
          isA<Success<void, Failure>>()); // Overall operation is successful

      // VERIFY
      verify(() => mockRemoteDataSource.delete(tId)).called(1);
      verify(() => mockLocalDataSource.delete(tId))
          .called(1); // Local delete was attempted
    });
  });
}
