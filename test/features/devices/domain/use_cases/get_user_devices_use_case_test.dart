import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/get_user_devices_use_case.dart';
import '../../../../fixtures/test_data.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late GetUserDevicesUseCase useCase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    useCase = GetUserDevicesUseCase(mockRepository);
  });

  group('GetUserDevicesUseCase', () {
    group('call', () {
      test('should return list of devices from repository', () async {
        // Arrange
        final testDevices = TestDeviceEntities.deviceList;
        when(() => mockRepository.getUserDevices())
            .thenAnswer((_) async => testDevices);

        // Act
        final result = await useCase();

        // Assert
        expect(result, testDevices);
        verify(() => mockRepository.getUserDevices()).called(1);
      });

      test('should return empty list when no devices exist', () async {
        // Arrange
        when(() => mockRepository.getUserDevices())
            .thenAnswer((_) async => []);

        // Act
        final result = await useCase();

        // Assert
        expect(result, isEmpty);
        verify(() => mockRepository.getUserDevices()).called(1);
      });

      test('should throw exception when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.getUserDevices())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockRepository.getUserDevices()).called(1);
      });
    });
  });
}
