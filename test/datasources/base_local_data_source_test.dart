// test/datasources/base_local_data_source_test.dart
import 'package:test/test.dart';
import '../datasources/mock_local_data_source.dart';
import '../entities/test_entity.dart' show TestEntity;

void main() {
  late MockLocalDataSource dataSource;

  setUp(() {
    dataSource = MockLocalDataSource();
  });

  group('BaseLocalDataSource', () {
    test('getAll returns empty list when empty', () async {
      final result = await dataSource.getAll();
      expect(result, isEmpty);
    });

    test('save and getById work correctly', () async {
      const entity = TestEntity(id: '1', name: 'Alice');
      await dataSource.save(entity);
      final retrieved = await dataSource.getById('1');
      expect(retrieved, entity);
    });

    test('exists returns true for existing id', () async {
      await dataSource.save(const TestEntity(id: '1', name: 'Alice'));
      expect(await dataSource.exists('1'), isTrue);
    });

    test('delete removes entity', () async {
      await dataSource.save(const TestEntity(id: '1', name: 'Alice'));
      await dataSource.delete('1');
      expect(await dataSource.exists('1'), isFalse);
    });

    test('clear removes all entities', () async {
      await dataSource.save(const TestEntity(id: '1', name: 'Alice'));
      await dataSource.save(const TestEntity(id: '2', name: 'Bob'));
      await dataSource.clear();
      expect(await dataSource.getAll(), isEmpty);
    });
  });
}
