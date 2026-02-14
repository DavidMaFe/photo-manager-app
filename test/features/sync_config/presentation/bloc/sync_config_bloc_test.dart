import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/get_sync_config_use_case.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/save_sync_config_use_case.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';

import '../../../../fixtures/test_data.dart';

class MockGetSyncConfigUseCase extends Mock implements GetSyncConfigUseCase {}

class MockSaveSyncConfigUseCase extends Mock implements SaveSyncConfigUseCase {}

class MockSyncSchedulerService extends Mock implements SyncSchedulerService {}

void main() {
  late MockGetSyncConfigUseCase mockGetSyncConfigUseCase;
  late MockSaveSyncConfigUseCase mockSaveSyncConfigUseCase;
  late MockSyncSchedulerService mockSyncSchedulerService;

  setUpAll(() {
    registerFallbackValue(TestSyncConfigs.dailySync);
  });

  setUp(() {
    mockGetSyncConfigUseCase = MockGetSyncConfigUseCase();
    mockSaveSyncConfigUseCase = MockSaveSyncConfigUseCase();
    mockSyncSchedulerService = MockSyncSchedulerService();

    // Default stub for rescheduleSync
    when(() => mockSyncSchedulerService.rescheduleSync(any()))
        .thenAnswer((_) async => {});
  });

  group('SyncConfigBloc', () {
    final testConfig = TestSyncConfigs.dailySync;

    test('initial state should be SyncConfigInitial', () {
      final bloc = SyncConfigBloc(
        getSyncConfigUseCase: mockGetSyncConfigUseCase,
        saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
        syncSchedulerService: mockSyncSchedulerService,
      );

      expect(bloc.state, isA<SyncConfigInitial>());
    });

    group('LoadSyncConfig', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should emit [SyncConfigLoading, SyncConfigLoaded] when load succeeds',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) => bloc.add(LoadSyncConfig()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config,
            'config',
            testConfig,
          ),
        ],
      );

      blocTest<SyncConfigBloc, SyncConfigState>(
        'should call getSyncConfigUseCase',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) => bloc.add(LoadSyncConfig()),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockGetSyncConfigUseCase()).called(1);
        },
      );

      blocTest<SyncConfigBloc, SyncConfigState>(
        'should emit [SyncConfigLoading, SyncConfigError] when load fails',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenThrow(Exception('Load failed'));
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) => bloc.add(LoadSyncConfig()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );
    });

    group('SaveSyncConfig', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should emit [SyncConfigSaving, SyncConfigSaved] when save succeeds',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          when(() => mockSaveSyncConfigUseCase(any()))
              .thenAnswer((_) async => Future.value());
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(SaveSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>(),
          isA<SyncConfigSaving>(),
          isA<SyncConfigSaved>(),
        ],
      );

      blocTest<SyncConfigBloc, SyncConfigState>(
        'should call saveSyncConfigUseCase with current config',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          when(() => mockSaveSyncConfigUseCase(any()))
              .thenAnswer((_) async => Future.value());
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(SaveSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
        },
        verify: (_) {
          verify(() => mockSaveSyncConfigUseCase(any())).called(1);
        },
      );

      blocTest<SyncConfigBloc, SyncConfigState>(
        'should emit error when saving without loading config first',
        build: () {
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) => bloc.add(SaveSyncConfig()),
        expect: () => [
          isA<SyncConfigError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );

      blocTest<SyncConfigBloc, SyncConfigState>(
        'should emit [SyncConfigSaving, SyncConfigError] when save fails',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          when(() => mockSaveSyncConfigUseCase(any()))
              .thenThrow(Exception('Save failed'));
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(SaveSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>(),
          isA<SyncConfigSaving>(),
          isA<SyncConfigError>(),
        ],
      );
    });

    group('ToggleAutoSync', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should update autoSyncEnabled to true',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => TestSyncConfigs.disabled);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(ToggleAutoSync(true));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.autoSyncEnabled,
            'autoSyncEnabled',
            false,
          ),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.autoSyncEnabled,
            'autoSyncEnabled',
            true,
          ),
        ],
      );
    });

    group('UpdateSyncFrequency', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should update sync frequency to weekly',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(UpdateSyncFrequency(SyncFrequency.weekly));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.syncFrequency,
            'syncFrequency',
            SyncFrequency.weekly,
          ),
        ],
      );

      blocTest<SyncConfigBloc, SyncConfigState>(
        'should clear day of week when switching to daily',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => TestSyncConfigs.weeklySync);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(UpdateSyncFrequency(SyncFrequency.daily));
          await Future.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.syncDayOfWeek,
            'syncDayOfWeek',
            1, // Weekly config has day 1
          ),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.syncDayOfWeek,
            'syncDayOfWeek',
            null, // Cleared when switching to daily
          ),
        ],
      );
    });

    group('UpdateSyncTime', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should update sync time',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(UpdateSyncTime(const TimeOfDay(hour: 14, minute: 30)));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>(),
          isA<SyncConfigLoaded>()
              .having((state) => state.config.syncHour, 'syncHour', 14)
              .having((state) => state.config.syncMinute, 'syncMinute', 30),
        ],
      );
    });

    group('UpdateSyncDayOfWeek', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should update day of week',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => TestSyncConfigs.weeklySync);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(UpdateSyncDayOfWeek(7)); // Sunday
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.syncDayOfWeek,
            'syncDayOfWeek',
            7,
          ),
        ],
      );
    });

    group('UpdateNetworkPreference', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should update network preference',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(UpdateNetworkPreference(NetworkPreference.anyNetwork));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.networkPreference,
            'networkPreference',
            NetworkPreference.anyNetwork,
          ),
        ],
      );
    });

    group('UpdateBatteryPreference', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should update battery preference',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(UpdateBatteryPreference(BatteryPreference.any));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.batteryPreference,
            'batteryPreference',
            BatteryPreference.any,
          ),
        ],
      );
    });

    group('ToggleNotifyOnSuccess', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should toggle notify on success',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => testConfig);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(ToggleNotifyOnSuccess(true));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.notifyOnSuccess,
            'notifyOnSuccess',
            false,
          ),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.notifyOnSuccess,
            'notifyOnSuccess',
            true,
          ),
        ],
      );
    });

    group('ToggleNotifyOnFailure', () {
      blocTest<SyncConfigBloc, SyncConfigState>(
        'should toggle notify on failure',
        build: () {
          when(() => mockGetSyncConfigUseCase())
              .thenAnswer((_) async => TestSyncConfigs.noNotifications);
          return SyncConfigBloc(
            getSyncConfigUseCase: mockGetSyncConfigUseCase,
            saveSyncConfigUseCase: mockSaveSyncConfigUseCase,
            syncSchedulerService: mockSyncSchedulerService,
          );
        },
        act: (bloc) async {
          bloc.add(LoadSyncConfig());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(ToggleNotifyOnFailure(true));
        },
        expect: () => [
          isA<SyncConfigLoading>(),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.notifyOnFailure,
            'notifyOnFailure',
            false,
          ),
          isA<SyncConfigLoaded>().having(
            (state) => state.config.notifyOnFailure,
            'notifyOnFailure',
            true,
          ),
        ],
      );
    });
  });
}
