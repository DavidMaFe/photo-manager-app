import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/rename_device_use_case.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late RenameDeviceUseCase useCase;
  late MockDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockDeviceRepository();
    useCase = RenameDeviceUseCase(mockRepository);
  });

  group('RenameDeviceUseCase', () {
    const testDeviceId = '1';
    const testNewName = 'My New Device Name';

    group('call', () {
      test('should call repository with trimmed device name', () async {
        // Arrange
        const nameWithSpaces = '  My New Device Name  ';
        when(() => mockRepository.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await useCase(deviceId: testDeviceId, newName: nameWithSpaces);

        // Assert
        verify(() => mockRepository.renameDevice(
              deviceId: testDeviceId,
              newName: nameWithSpaces.trim(),
            )).called(1);
      });

      test('should successfully rename device when name is valid', () async {
        // Arrange
        when(() => mockRepository.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await useCase(deviceId: testDeviceId, newName: testNewName);

        // Assert
        verify(() => mockRepository.renameDevice(
              deviceId: testDeviceId,
              newName: testNewName,
            )).called(1);
      });

      test('should throw exception when new name is empty', () async {
        // Act & Assert
        expect(
          () => useCase(deviceId: testDeviceId, newName: ''),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Device name cannot be empty')),
          ),
        );

        // Verify repository was never called
        verifyNever(() => mockRepository.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            ));
      });

      test('should throw exception when new name contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(deviceId: testDeviceId, newName: '   '),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Device name cannot be empty')),
          ),
        );

        // Verify repository was never called
        verifyNever(() => mockRepository.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            ));
      });

      test('should throw exception when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase(deviceId: testDeviceId, newName: testNewName),
          throwsA(isA<Exception>()),
        );
        verify(() => mockRepository.renameDevice(
              deviceId: testDeviceId,
              newName: testNewName,
            )).called(1);
      });
    });
  });
}
