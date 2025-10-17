// test/models/base_model_test.dart
import 'package:test/test.dart';
import '../models/test_user_model.dart';
import '../entities/test_user_entity.dart';

void main() {
  group('BaseModel', () {
    final model = UserModel(id: '1', name: 'Alice', age: 30);
    const entity = UserEntity(id: '1', name: 'Alice', age: 30);

    test('toJson returns correct JSON', () {
      final json = model.toJson();
      expect(json, {
        'id': '1',
        'name': 'Alice',
        'age': 30,
      });
    });

    test('fromJson creates correct instance', () {
      final json = {'id': '2', 'name': 'Bob', 'age': 25};
      final model = UserModel.fromJson(json);
      expect(model.id, '2');
      expect(model.name, 'Bob');
      expect(model.age, 25);
    });

    test('toEntity converts to correct entity', () {
      final converted = model.toEntity();
      expect(converted, entity);
    });

    test('value equality works', () {
      final model2 = UserModel(id: '1', name: 'Alice', age: 30);
      expect(model, model2);
      expect(model.hashCode, model2.hashCode);
    });

    test('different models are not equal', () {
      final model2 = UserModel(id: '2', name: 'Alice', age: 30);
      expect(model == model2, isFalse);
    });

    test('toString returns readable output', () {
      expect(model.toString(), 'UserModel(1, Alice, 30)');
    });
  });
}
