// test/domain/usecases/get_example_data_usecase_test.dart
import 'package:flutter_core/src/core/domain/failures/failures.dart';
import 'package:flutter_core/src/core/domain/usecases/example_use_case.dart'
    hide MockExampleRepository;
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_example_repository.dart' show MockExampleRepository;

void main() {
  late MockExampleRepository mockRepository;
  late GetExampleDataUseCase useCase;

  setUp(() {
    mockRepository = MockExampleRepository();
    useCase = GetExampleDataUseCase(mockRepository);
  });

  test('execute returns Success when repository succeeds', () async {
    const entity = ExampleEntity(id: '1', data: 'test');
    when(() => mockRepository.getExampleData('1', null))
        .thenAnswer((_) async => const Success(entity));

    final result = await useCase.execute(const ExampleParams(id: '1'));

    expect(result.isSuccess, isTrue);
    expect(result.data, entity);
  });

  test('execute returns Error when repository fails', () async {
    const failure = NetworkFailure(message: 'Network error');
    when(() => mockRepository.getExampleData('1', null))
        .thenAnswer((_) async => const Error(failure));

    final result = await useCase.execute(const ExampleParams(id: '1'));

    expect(result.isFailure, isTrue);
    expect(result.failure, failure);
  });
}

// // test/domain/usecases/get_example_data_usecase_test.dart
// import 'package:flutter_core/flutter_core.dart';
// import 'package:flutter_core/src/core/domain/usecases/example_use_case.dart';
// import 'package:mocktail/mocktail.dart' show when;
// import 'package:test/test.dart';

// void main() {
//   late MockExampleRepository mockRepository;
//   late GetExampleDataUseCase useCase;

//   setUp(() {
//     mockRepository = MockExampleRepository();
//     useCase = GetExampleDataUseCase(mockRepository);
//   });

//   test('execute returns Success when repository succeeds', () async {
//     const entity = ExampleEntity(id: '1', data: 'test');
//     when(() => mockRepository.getExampleData('1', null))
//         .thenAnswer((_) async => const Success(entity));

//     final result = await useCase(const ExampleParams(id: '1'));

//     expect(result.isSuccess, isTrue);
//     expect(result.data, entity);
//   });

//   test('execute returns Error when repository fails', () async {
//     const failure = NetworkFailure(message: 'Network error');
//     when(() => mockRepository.getExampleData('1', null))
//         .thenAnswer((_) async => const Error(failure));

//     final result = await useCase(const ExampleParams(id: '1'));

//     expect(result.isFailure, isTrue);
//     expect(result.failure, failure);
//   });
// }
