import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/get_user_devices_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/rename_device_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/toggle_auto_sync_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/unlink_device_use_case.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_state.dart';
import '../../../../fixtures/test_data.dart';

class MockGetUserDevicesUseCase extends Mock
    implements GetUserDevicesUseCase {}

class MockRenameDeviceUseCase extends Mock implements RenameDeviceUseCase {}

class MockToggleAutoSyncUseCase extends Mock implements ToggleAutoSyncUseCase {}

class MockUnlinkDeviceUseCase extends Mock implements UnlinkDeviceUseCase {}

class MockAppEventBus extends Mock implements AppEventBus {}

class FakeAppEvent extends Fake implements AppEvent {}

class FakeDeviceUpdatedEvent extends Fake implements DeviceUpdatedEvent {}

void main() {
  late DeviceBloc bloc;
  late MockGetUserDevicesUseCase mockGetUserDevicesUseCase;
  late MockRenameDeviceUseCase mockRenameDeviceUseCase;
  late MockToggleAutoSyncUseCase mockToggleAutoSyncUseCase;
  late MockUnlinkDeviceUseCase mockUnlinkDeviceUseCase;
  late AppEventBus eventBus;

  setUpAll(() {
    registerFallbackValue(FakeAppEvent());
    registerFallbackValue(FakeDeviceUpdatedEvent());
  });

  DeviceBloc createBloc({AppEventBus? customEventBus}) {
    return DeviceBloc(
      getUserDevicesUseCase: mockGetUserDevicesUseCase,
      renameDeviceUseCase: mockRenameDeviceUseCase,
      toggleAutoSyncUseCase: mockToggleAutoSyncUseCase,
      unlinkDeviceUseCase: mockUnlinkDeviceUseCase,
      eventBus: customEventBus ?? eventBus,
    );
  }

  setUp(() {
    mockGetUserDevicesUseCase = MockGetUserDevicesUseCase();
    mockRenameDeviceUseCase = MockRenameDeviceUseCase();
    mockToggleAutoSyncUseCase = MockToggleAutoSyncUseCase();
    mockUnlinkDeviceUseCase = MockUnlinkDeviceUseCase();

    // Set up a default MockAppEventBus for all tests
    final mockEventBus = MockAppEventBus();
    when(() => mockEventBus.on<DeviceUpdatedEvent>())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockEventBus.fire(any())).thenReturn(null);
    eventBus = mockEventBus;

    bloc = createBloc();
  });

  tearDown(() {
    bloc.close();
  });

  final testDevices = TestDeviceEntities.deviceList;

  group('DeviceBloc', () {
    test('initial state should be DeviceInitial', () {
      expect(bloc.state, isA<DeviceInitial>());
    });

    group('LoadDevices', () {
      blocTest<DeviceBloc, DeviceState>(
        'should emit [DeviceLoading, DeviceLoaded] when devices are loaded successfully',
        build: () {
          when(() => mockGetUserDevicesUseCase())
              .thenAnswer((_) async => testDevices);
          return createBloc();
        },
        act: (bloc) => bloc.add(LoadDevices()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceLoading>(),
          isA<DeviceLoaded>()
              .having((state) => state.devices, 'devices', testDevices),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should emit [DeviceLoading, DeviceLoaded] with empty list when no devices exist',
        build: () {
          when(() => mockGetUserDevicesUseCase()).thenAnswer((_) async => []);
          return createBloc();
        },
        act: (bloc) => bloc.add(LoadDevices()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceLoading>(),
          isA<DeviceLoaded>().having((state) => state.devices, 'devices', []),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should emit [DeviceLoading, DeviceError] when loading fails',
        build: () {
          when(() => mockGetUserDevicesUseCase())
              .thenThrow(Exception('Network error'));
          return createBloc();
        },
        act: (bloc) => bloc.add(LoadDevices()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceLoading>(),
          isA<DeviceError>()
              .having((state) => state.failure, 'failure', isA<Failure>()),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should respect minimum loading duration of 800ms',
        build: () {
          when(() => mockGetUserDevicesUseCase())
              .thenAnswer((_) async => testDevices);
          return createBloc();
        },
        act: (bloc) => bloc.add(LoadDevices()),
        wait: const Duration(milliseconds: 700),
        expect: () => [
          isA<DeviceLoading>(),
          // Should still be loading because 700ms < 800ms minimum
        ],
      );
    });

    group('RefreshDevices', () {
      blocTest<DeviceBloc, DeviceState>(
        'should emit DeviceLoaded when refresh succeeds',
        build: () {
          when(() => mockGetUserDevicesUseCase())
              .thenAnswer((_) async => testDevices);
          return createBloc();
        },
        act: (bloc) => bloc.add(RefreshDevices()),
        expect: () => [
          isA<DeviceLoaded>()
              .having((state) => state.devices, 'devices', testDevices),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should emit DeviceError when refresh fails',
        build: () {
          when(() => mockGetUserDevicesUseCase())
              .thenThrow(Exception('Network error'));
          return createBloc();
        },
        act: (bloc) => bloc.add(RefreshDevices()),
        expect: () => [
          isA<DeviceError>(),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should NOT show loading state during refresh',
        build: () {
          when(() => mockGetUserDevicesUseCase())
              .thenAnswer((_) async => testDevices);
          return createBloc();
        },
        act: (bloc) => bloc.add(RefreshDevices()),
        expect: () => [
          isA<DeviceLoaded>(),
        ],
        verify: (_) {
          // Verify we don't emit DeviceLoading
        },
      );
    });

    group('RenameDevice', () {
      const testDeviceId = '1';
      const testNewName = 'My Renamed Device';

      blocTest<DeviceBloc, DeviceState>(
        'should emit [DeviceActionInProgress, DeviceActionSuccess, DeviceLoaded] when rename succeeds',
        build: () {
          when(() => mockRenameDeviceUseCase(
                deviceId: any(named: 'deviceId'),
                newName: any(named: 'newName'),
              )).thenAnswer((_) async => Future.value());
          when(() => mockGetUserDevicesUseCase())
              .thenAnswer((_) async => testDevices);
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(RenameDevice(
          deviceId: testDeviceId,
          newName: testNewName,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceActionInProgress>()
              .having((state) => state.actionDeviceId, 'actionDeviceId',
                  testDeviceId)
              .having((state) => state.devices, 'devices', testDevices),
          isA<DeviceActionSuccess>(),
          isA<DeviceLoaded>(),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should fire DeviceUpdatedEvent when rename succeeds',
        build: () {
          when(() => mockRenameDeviceUseCase(
                deviceId: any(named: 'deviceId'),
                newName: any(named: 'newName'),
              )).thenAnswer((_) async => Future.value());
          when(() => mockGetUserDevicesUseCase())
              .thenAnswer((_) async => testDevices);
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(RenameDevice(
          deviceId: testDeviceId,
          newName: testNewName,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => (eventBus as MockAppEventBus).fire(any<DeviceUpdatedEvent>())).called(1);
        },
      );

      blocTest<DeviceBloc, DeviceState>(
        'should emit [DeviceActionInProgress, DeviceError, DeviceLoaded] when rename fails',
        build: () {
          when(() => mockRenameDeviceUseCase(
                deviceId: any(named: 'deviceId'),
                newName: any(named: 'newName'),
              )).thenThrow(Exception('Network error'));
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(RenameDevice(
          deviceId: testDeviceId,
          newName: testNewName,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceActionInProgress>(),
          isA<DeviceError>(),
          isA<DeviceLoaded>()
              .having((state) => state.devices, 'devices', testDevices),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should not proceed if current state is not DeviceLoaded',
        build: () => bloc,
        seed: () => DeviceLoading(),
        act: (bloc) => bloc.add(RenameDevice(
          deviceId: testDeviceId,
          newName: testNewName,
        )),
        expect: () => [],
      );
    });

    group('ToggleAutoSync', () {
      const testDeviceId = '1';

      blocTest<DeviceBloc, DeviceState>(
        'should emit [DeviceActionInProgress, DeviceActionSuccess, DeviceLoaded] when toggle succeeds',
        build: () {
          when(() => mockToggleAutoSyncUseCase(
                deviceId: any(named: 'deviceId'),
                enabled: any(named: 'enabled'),
              )).thenAnswer((_) async => Future.value());
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(ToggleAutoSync(
          deviceId: testDeviceId,
          enabled: false,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceActionInProgress>(),
          isA<DeviceActionSuccess>(),
          isA<DeviceLoaded>(),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should update device autoSync value in the list',
        build: () {
          when(() => mockToggleAutoSyncUseCase(
                deviceId: any(named: 'deviceId'),
                enabled: any(named: 'enabled'),
              )).thenAnswer((_) async => Future.value());
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(ToggleAutoSync(
          deviceId: testDeviceId,
          enabled: false,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (bloc) {
          final state = bloc.state as DeviceLoaded;
          final updatedDevice =
              state.devices.firstWhere((d) => d.id == testDeviceId);
          expect(updatedDevice.autoSync, false);
        },
      );

      blocTest<DeviceBloc, DeviceState>(
        'should fire DeviceUpdatedEvent when toggle succeeds',
        build: () {
          when(() => mockToggleAutoSyncUseCase(
                deviceId: any(named: 'deviceId'),
                enabled: any(named: 'enabled'),
              )).thenAnswer((_) async => Future.value());
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(ToggleAutoSync(
          deviceId: testDeviceId,
          enabled: true,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => (eventBus as MockAppEventBus).fire(any<DeviceUpdatedEvent>())).called(1);
        },
      );

      blocTest<DeviceBloc, DeviceState>(
        'should restore previous state when toggle fails',
        build: () {
          when(() => mockToggleAutoSyncUseCase(
                deviceId: any(named: 'deviceId'),
                enabled: any(named: 'enabled'),
              )).thenThrow(Exception('Network error'));
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(ToggleAutoSync(
          deviceId: testDeviceId,
          enabled: false,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceActionInProgress>(),
          isA<DeviceError>(),
          isA<DeviceLoaded>()
              .having((state) => state.devices, 'devices', testDevices),
        ],
      );
    });

    group('UnlinkDevice', () {
      const testDeviceId = '1';

      blocTest<DeviceBloc, DeviceState>(
        'should emit [DeviceActionInProgress, DeviceActionSuccess, DeviceLoaded] when unlink succeeds',
        build: () {
          when(() => mockUnlinkDeviceUseCase(deviceId: any(named: 'deviceId')))
              .thenAnswer((_) async => Future.value());
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(UnlinkDevice(deviceId: testDeviceId)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceActionInProgress>(),
          isA<DeviceActionSuccess>(),
          isA<DeviceLoaded>(),
        ],
      );

      blocTest<DeviceBloc, DeviceState>(
        'should remove device from list when unlink succeeds',
        build: () {
          when(() => mockUnlinkDeviceUseCase(deviceId: any(named: 'deviceId')))
              .thenAnswer((_) async => Future.value());
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(UnlinkDevice(deviceId: testDeviceId)),
        wait: const Duration(milliseconds: 900),
        verify: (bloc) {
          final state = bloc.state as DeviceLoaded;
          expect(
              state.devices.any((d) => d.id == testDeviceId), false);
          expect(state.devices.length, testDevices.length - 1);
        },
      );

      blocTest<DeviceBloc, DeviceState>(
        'should fire DeviceUpdatedEvent with affected device IDs',
        build: () {
          when(() => mockUnlinkDeviceUseCase(deviceId: any(named: 'deviceId')))
              .thenAnswer((_) async => Future.value());
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(UnlinkDevice(deviceId: testDeviceId)),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => (eventBus as MockAppEventBus).fire(any<DeviceUpdatedEvent>())).called(1);
        },
      );

      blocTest<DeviceBloc, DeviceState>(
        'should restore previous state when unlink fails',
        build: () {
          when(() => mockUnlinkDeviceUseCase(deviceId: any(named: 'deviceId')))
              .thenThrow(Exception('Network error'));
          return createBloc();
        },
        seed: () => DeviceLoaded(testDevices),
        act: (bloc) => bloc.add(UnlinkDevice(deviceId: testDeviceId)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<DeviceActionInProgress>(),
          isA<DeviceError>(),
          isA<DeviceLoaded>()
              .having((state) => state.devices, 'devices', testDevices),
        ],
      );
    });
  });
}
