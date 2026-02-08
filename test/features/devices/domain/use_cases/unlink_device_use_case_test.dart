import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/unlink_device_use_case.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late UnlinkDeviceUseCase useCase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    useCase = UnlinkDeviceUseCase(mockRepository);
  });

  group('UnlinkDeviceUseCase', () {
    const testDeviceId = '1';

    group('call', () {
      test('should successfully unlink device', () async {
        // Arrange
        when(() => mockRepository.unlinkDevice(
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await useCase(deviceId: testDeviceId);

        // Assert
        verify(() => mockRepository.unlinkDevice(
              deviceId: testDeviceId,
            )).called(1);
      });

      test('should throw exception when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.unlinkDevice(
              deviceId: any(named: 'deviceId'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase(deviceId: testDeviceId),
          throwsA(isA<Exception>()),
        );
        verify(() => mockRepository.unlinkDevice(
              deviceId: testDeviceId,
            )).called(1);
      });

      test('should throw exception when device not found', () async {
        // Arrange
        when(() => mockRepository.unlinkDevice(
              deviceId: any(named: 'deviceId'),
            )).thenThrow(Exception('Device not found'));

        // Act & Assert
        expect(
          () => useCase(deviceId: 'non-existent-id'),
          throwsA(isA<Exception>()),
        );
        verify(() => mockRepository.unlinkDevice(
              deviceId: 'non-existent-id',
            )).called(1);
      });
    });
  });
}
