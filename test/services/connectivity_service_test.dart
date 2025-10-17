// test/services/connectivity_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_core/src/core/services/connectivity_service.dart';
import '../mocks/mock_connectivity.dart';

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityService service;

  setUp(() {
    mockConnectivity = MockConnectivity();
    // Inject mock via private field (only way since Connectivity is final)
    // We'll use dynamic assignment for testing
    ConnectivityService.reset(testConnectivity: mockConnectivity);
    // (ConnectivityService._instance ??= ConnectivityService._())._connectivity =
    //     mockConnectivity;

    service = ConnectivityService.instance;
  });

  group('ConnectivityX extension', () {
    test('isOnline returns true for mobile', () {
      expect([ConnectivityResult.mobile].isOnline, isTrue);
    });

    test('isOnline returns true for wifi', () {
      expect([ConnectivityResult.wifi].isOnline, isTrue);
    });

    test('isOnline returns true for ethernet', () {
      expect([ConnectivityResult.ethernet].isOnline, isTrue);
    });

    test('isOnline returns true for vpn', () {
      expect([ConnectivityResult.vpn].isOnline, isTrue);
    });

    test('isOnline returns false for none', () {
      expect([ConnectivityResult.none].isOnline, isFalse);
    });

    test('isOnline returns false for empty list', () {
      expect(<ConnectivityResult>[].isOnline, isFalse);
    });

    test('isOnline returns true if any connection is online', () {
      expect(
          [
            ConnectivityResult.none,
            ConnectivityResult.mobile,
            ConnectivityResult.bluetooth,
          ].isOnline,
          isTrue);
    });
  });

  group('ConnectivityService', () {
    test('hasConnection returns true when online', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await service.hasConnection();
      expect(result, isTrue);
    });

    test('hasConnection returns false when offline', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await service.hasConnection();
      expect(result, isFalse);
    });

    test('hasConnection returns false on error', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Network error'));

      final result = await service.hasConnection();
      expect(result, isFalse);
    });

    test('getCurrentConnectivity returns results on success', () async {
      final mockResults = [ConnectivityResult.mobile];
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => mockResults);

      final result = await service.getCurrentConnectivity();
      expect(result, mockResults);
    });

    test('getCurrentConnectivity returns empty list on error', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Network error'));

      final result = await service.getCurrentConnectivity();
      expect(result, isEmpty);
    });

    test('listenToConnectivityChanges forwards stream events', () async {
      final mockStream = Stream<List<ConnectivityResult>>.fromIterable([
        [ConnectivityResult.wifi],
        [ConnectivityResult.none],
      ]);
      // ✅ FIX: Use thenAnswer for Streams
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => mockStream);

      final events = <List<ConnectivityResult>>[];
      final subscription = service.listenToConnectivityChanges(
        onData: (results) => events.add(results),
      );

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(events, [
        [ConnectivityResult.wifi],
        [ConnectivityResult.none],
      ]);
    });

    test('cancelConnectivitySubscription cancels safely', () async {
      final mockStream = Stream<List<ConnectivityResult>>.value([]);
      // ✅ FIX: Use thenAnswer for Streams
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => mockStream);

      final subscription = service.listenToConnectivityChanges(
        onData: (_) {},
      );

      // Should not throw
      service.cancelConnectivitySubscription(subscription);
    });
  });
}
