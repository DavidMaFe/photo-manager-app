import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_event_log.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_events.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_event.dart';
import 'package:photo_manager_app/core/services/background_sync_service.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/get_user_plan_use_case.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_file_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/upload_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/storage_budget.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/sync_keep_alive.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/test_data.dart';
import '../../helpers/plan_test_providers.dart';

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}
class MockSyncConfigRepository extends Mock implements SyncConfigRepository {}
class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}
class MockStartSyncSessionUseCase extends Mock implements StartSyncSessionUseCase {}
class MockCheckDuplicatedFilesUseCase extends Mock implements CheckDuplicatedFilesUseCase {}
class MockUploadFileUseCase extends Mock implements UploadFileUseCase {}
class MockCompleteSyncSessionUseCase extends Mock implements CompleteSyncSessionUseCase {}
class MockMediaLocalDataSource extends Mock implements MediaLocalDataSource {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockSyncNotificationService extends Mock implements SyncNotificationService {}
class MockSyncLock extends Mock implements SyncLock {}
class MockSyncKeepAlive extends Mock implements SyncKeepAlive {}
class MockGetUserPlanUseCase extends Mock implements GetUserPlanUseCase {}
class MockAppEventLog extends Mock implements AppEventLog {}
class MockConnectivity extends Mock implements Connectivity {}
class MockBattery extends Mock implements Battery {}
class FakeSyncFile extends Fake implements SyncFile {}
class FakeStorageBudget extends Fake implements StorageBudget {}
class FakeAppLogEvent extends Fake implements AppLogEvent {}

void main() {
  const sessionId = 'session-1';
  const deviceUuid = 'device-1';

  late MockStartSyncSessionUseCase startUseCase;
  late MockCheckDuplicatedFilesUseCase checkDuplicatesUseCase;
  late MockUploadFileUseCase uploadUseCase;
  late MockCompleteSyncSessionUseCase completeUseCase;
  late MockSyncSessionRepository sessionRepository;
  late MockMediaLocalDataSource mediaDataSource;
  late MockSyncNotificationService notificationService;
  late MockGetUserPlanUseCase getUserPlan;
  late MockAppEventLog appEventLog;
  late MockSyncConfigRepository configRepository;
  late BackgroundSyncService service;

  SyncFileModel image(String hash, int sizeBytes) => SyncFileModel(
        localId: 'local-$hash',
        devicePath: '/photos/$hash.jpg',
        hash: hash,
        fileName: '$hash.jpg',
        sizeBytes: sizeBytes,
        capturedAt: DateTime(2026, 10, 1),
        mimeType: 'image/jpeg',
      );

  final big = image('big', 100 * testMib);
  final tooBig = image('too-big', 80 * testMib);
  final small = image('small', 10 * testMib);

  SyncConfig config({bool notifyOnFailure = true}) => SyncConfig(
        autoSyncEnabled: true,
        syncFrequency: SyncFrequency.daily,
        syncHour: 2,
        syncMinute: 0,
        networkPreference: NetworkPreference.anyNetwork,
        batteryPreference: BatteryPreference.any,
        notifyOnSuccess: false,
        notifyOnFailure: notifyOnFailure,
      );

  setUpAll(() {
    registerFallbackValue(FakeSyncFile());
    registerFallbackValue(FakeStorageBudget());
    registerFallbackValue(FakeAppLogEvent());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final deviceRepository = MockSyncDeviceRepository();
    configRepository = MockSyncConfigRepository();
    sessionRepository = MockSyncSessionRepository();
    startUseCase = MockStartSyncSessionUseCase();
    checkDuplicatesUseCase = MockCheckDuplicatedFilesUseCase();
    uploadUseCase = MockUploadFileUseCase();
    completeUseCase = MockCompleteSyncSessionUseCase();
    mediaDataSource = MockMediaLocalDataSource();
    final authRepository = MockAuthRepository();
    notificationService = MockSyncNotificationService();
    final syncLock = MockSyncLock();
    final keepAlive = MockSyncKeepAlive();
    getUserPlan = MockGetUserPlanUseCase();
    appEventLog = MockAppEventLog();
    final connectivity = MockConnectivity();

    // 150 MiB free
    when(() => getUserPlan()).thenAnswer((_) async => TestPlans.freeWithStored(5 * testGib - 150 * testMib));
    when(() => syncLock.check()).thenAnswer((_) async => const SyncLockCheck(SyncLockStatus.free));
    when(() => syncLock.acquire()).thenAnswer((_) async {});
    when(() => syncLock.release()).thenAnswer((_) async {});
    when(() => keepAlive.start()).thenAnswer((_) async {});
    when(() => keepAlive.stop()).thenAnswer((_) async {});
    when(() => keepAlive.update(current: any(named: 'current'), total: any(named: 'total'))).thenAnswer((_) async {});
    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => TestUsers.johnDoe);
    when(() => configRepository.getSyncConfig()).thenAnswer((_) async => config());
    when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(() => deviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
    when(() => startUseCase(deviceUuid: deviceUuid)).thenAnswer((_) async => SyncSession(id: sessionId));
    // No server id: the file mapping (database) is not written
    when(() => uploadUseCase(sessionId: sessionId, file: any(named: 'file'), budget: any(named: 'budget')))
        .thenAnswer((_) async => const UploadResult());
    when(() => completeUseCase(sessionId: sessionId))
        .thenAnswer((_) async => SyncResult(totalFiles: 0, uploadedFiles: 0, failedFiles: 0));
    when(() => sessionRepository.cancelSyncSession(sessionId: any(named: 'sessionId'))).thenAnswer((_) async {});
    when(() => notificationService.showStorageFullNotification(
        files: any(named: 'files'), bytes: any(named: 'bytes'))).thenAnswer((_) async {});
    when(() => notificationService.showSyncFailureNotification(
        sessionExpired: any(named: 'sessionExpired'), planLimit: any(named: 'planLimit'))).thenAnswer((_) async {});

    service = BackgroundSyncService(
      syncDeviceRepository: deviceRepository,
      syncConfigRepository: configRepository,
      syncSessionRepository: sessionRepository,
      startSyncSessionUseCase: startUseCase,
      checkDuplicatesUseCase: checkDuplicatesUseCase,
      uploadFileUseCase: uploadUseCase,
      completeSyncSessionUseCase: completeUseCase,
      mediaLocalDataSource: mediaDataSource,
      authRepository: authRepository,
      sharedPreferences: prefs,
      notificationService: notificationService,
      syncLogService: SyncLogService(prefs),
      syncLock: syncLock,
      syncKeepAlive: keepAlive,
      getUserPlanUseCase: getUserPlan,
      appEventLog: appEventLog,
      connectivity: connectivity,
      battery: MockBattery(),
    );
  });

  void givenPendingFiles(List<SyncFileModel> files) {
    when(() => mediaDataSource.scanMediaFiles(
          lastCompletedSyncAt: any(named: 'lastCompletedSyncAt'),
          skipPermissionCheck: true,
        )).thenAnswer((_) async => files);
    when(() => checkDuplicatesUseCase(sessionId: sessionId, fileHashes: any(named: 'fileHashes')))
        .thenAnswer((_) async => DuplicateFilesResult(
            filesToUpload: files.map((file) => file.hash).toList(), duplicatesCount: 0, totalFiles: files.length));
  }

  void givenUploadFails(SyncFile file, Object error) {
    when(() => uploadUseCase(sessionId: sessionId, file: file, budget: any(named: 'budget'))).thenThrow(error);
  }

  ApiException noSpaceLeft() => ApiException(ErrorResponseModel(
      code: FailureCodes.userDoesNotHaveStorageSpace, message: 'No space', timestamp: '2026-10-21T10:00:00'));

  group('BackgroundSyncService', () {
    group('free space of the plan', () {
      test('should skip a file that does not fit, back up the rest and say what was left out', () async {
        // Given
        givenPendingFiles([big, tooBig, small]);
        givenUploadFails(tooBig, const FileDoesNotFitFailure(81 * testMib));

        // When
        final success = await service.execute();

        // Then
        expect(success, isTrue);
        verify(() => uploadUseCase(sessionId: sessionId, file: small, budget: any(named: 'budget'))).called(1);
        verify(() => completeUseCase(sessionId: sessionId)).called(1);
        verifyNever(() => sessionRepository.cancelSyncSession(sessionId: any(named: 'sessionId')));
        verify(() => notificationService.showStorageFullNotification(files: 1, bytes: 81 * testMib)).called(1);
        final event = verify(() => appEventLog.record(captureAny())).captured.single as SyncStorageFull;
        expect(event.name, 'SYNC_STORAGE_FULL');
        expect(event.message, 'background=true files=1 bytes=${81 * testMib}');
      });

      test('should read the plan again and go on when the server has no space left', () async {
        // Given
        givenPendingFiles([big, small]);
        givenUploadFails(big, noSpaceLeft());

        // When
        final success = await service.execute();

        // Then: no longer a limit that stops the backup
        expect(success, isTrue);
        verify(() => getUserPlan()).called(2);
        verify(() => uploadUseCase(sessionId: sessionId, file: small, budget: any(named: 'budget'))).called(1);
        verifyNever(() => sessionRepository.cancelSyncSession(sessionId: any(named: 'sessionId')));
        verifyNever(() => notificationService.showSyncFailureNotification(
            sessionExpired: any(named: 'sessionExpired'), planLimit: any(named: 'planLimit')));
        verify(() => notificationService.showStorageFullNotification(files: 1, bytes: 100 * testMib)).called(1);
        expect(service.wasLastFailureAuthRelated(), isFalse);
      });

      test('should not notify when the user turned off the failure notifications, but still record it', () async {
        // Given
        when(() => configRepository.getSyncConfig()).thenAnswer((_) async => config(notifyOnFailure: false));
        givenPendingFiles([tooBig]);
        givenUploadFails(tooBig, const FileDoesNotFitFailure(81 * testMib));

        // When
        await service.execute();

        // Then
        verifyNever(() => notificationService.showStorageFullNotification(
            files: any(named: 'files'), bytes: any(named: 'bytes')));
        verify(() => appEventLog.record(any(that: isA<SyncStorageFull>()))).called(1);
      });

      test('should neither notify nor record anything when every file fits', () async {
        // Given
        givenPendingFiles([small]);

        // When
        final success = await service.execute();

        // Then
        expect(success, isTrue);
        verifyNever(() => notificationService.showStorageFullNotification(
            files: any(named: 'files'), bytes: any(named: 'bytes')));
        verifyNever(() => appEventLog.record(any()));
      });

      test('should still stop the backup on a limit of the plan that is not the space', () async {
        // Given
        givenPendingFiles([big, small]);
        givenUploadFails(big, ApiException(ErrorResponseModel(
            code: FailureCodes.devicePaused, message: 'Paused', timestamp: '2026-10-21T10:00:00')));

        // When
        final success = await service.execute();

        // Then
        expect(success, isFalse);
        verifyNever(() => uploadUseCase(sessionId: sessionId, file: small, budget: any(named: 'budget')));
        verify(() => sessionRepository.cancelSyncSession(sessionId: sessionId)).called(1);
        verify(() => notificationService.showSyncFailureNotification(sessionExpired: false, planLimit: true))
            .called(1);
      });
    });
  });
}
