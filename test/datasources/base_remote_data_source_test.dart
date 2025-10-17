// test/datasources/base_remote_data_source_test.dart
import 'package:test/test.dart';
import '../models/test_model.dart';
import '../datasources/mock_remote_data_source.dart';

void main() {
  late MockRemoteDataSource dataSource;

  setUp(() {
    dataSource = MockRemoteDataSource();
  });

  group('BaseRemoteDataSource', () {
    test('getAll returns all models', () async {
      final result = await dataSource.getAll();
      expect(result.length, 2);
    });

    test('getById returns correct model', () async {
      final result = await dataSource.getById('1');
      expect(result.name, 'Alice');
    });

    test('create adds new model', () async {
      final newModel = TestModel(id: '3', name: 'Charlie');
      await dataSource.create(newModel);
      final result = await dataSource.getById('3');
      expect(result, newModel);
    });

    test('search filters by name', () async {
      final result = await dataSource.search(query: 'ali');
      expect(result.length, 1);
      expect(result.first.name, 'Alice');
    });

    test('getPaginated returns correct page', () async {
      final result = await dataSource.getPaginated(page: 2, limit: 1);
      expect(result.length, 1);
      expect(result.first.id, '2');
    });
  });
}
