// test/mocks/mock_example_repository.dart
import 'package:flutter_core/src/core/domain/usecases/example_use_case.dart'
    show IExampleRepository;
import 'package:mocktail/mocktail.dart';

class MockExampleRepository extends Mock implements IExampleRepository {}
