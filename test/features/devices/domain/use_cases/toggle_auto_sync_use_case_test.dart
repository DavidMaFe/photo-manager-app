import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/toggle_auto_sync_use_case.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late ToggleAutoSyncUseCase useCase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    useCase = ToggleAutoSyncUseCase(mockRepository);
  });

  group('ToggleAutoSyncUseCase', () {
    const testDeviceId = '1';

    group('call', () {
      test('should successfully enable auto sync', () async {
        // Arrange
        when(() => mockRepository.toggleAutoSync(
              deviceId: any(named: 'deviceId'),
              enabled: any(named: 'enabled'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await useCase(deviceId: testDeviceId, enabled: true);

        // Assert
        verify(() => mockRepository.toggleAutoSync(
              deviceId: testDeviceId,
              enabled: true,
            )).called(1);
      });

      test('should successfully disable auto sync', () async {
        // Arrange
        when(() => mockRepository.toggleAutoSync(
              deviceId: any(named: 'deviceId'),
              enabled: any(named: 'enabled'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await useCase(deviceId: testDeviceId, enabled: false);

        // Assert
        verify(() => mockRepository.toggleAutoSync(
              deviceId: testDeviceId,
              enabled: false,
            )).called(1);
      });

      test('should throw exception when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.toggleAutoSync(
              deviceId: any(named: 'deviceId'),
              enabled: any(named: 'enabled'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase(deviceId: testDeviceId, enabled: true),
          throwsA(isA<Exception>()),
        );
        verify(() => mockRepository.toggleAutoSync(
              deviceId: testDeviceId,
              enabled: true,
            )).called(1);
      });
    });
  });
}
