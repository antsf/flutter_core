// test/entities/base_entity_test.dart
import 'package:test/test.dart';
import '../entities/test_user_entity.dart';

void main() {
  group('BaseEntity', () {
    const entity = UserEntity(id: '1', name: 'Alice', age: 30);

    test('toJson returns correct JSON', () {
      final json = entity.toJson();
      expect(json, {
        'id': '1',
        'name': 'Alice',
        'age': 30,
      });
    });

    test('fromJson creates correct instance', () {
      final json = {'id': '2', 'name': 'Bob', 'age': 25};
      final entity = UserEntity.fromJson(json);
      expect(entity.id, '2');
      expect(entity.name, 'Bob');
      expect(entity.age, 25);
    });

    test('value equality works', () {
      const entity2 = UserEntity(id: '1', name: 'Alice', age: 30);
      expect(entity, entity2);
      expect(entity.hashCode, entity2.hashCode);
    });

    test('different entities are not equal', () {
      const entity2 = UserEntity(id: '2', name: 'Alice', age: 30);
      expect(entity == entity2, isFalse);
    });

    test('toString returns readable output', () {
      expect(entity.toString(), 'UserEntity(1, Alice, 30)');
    });
  });
}
