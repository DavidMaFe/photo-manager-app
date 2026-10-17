import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/features/downloads/data/services/background_download_service.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/process_download_queue_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../downloads_mocks.dart';

class MockProcessDownloadQueueUseCase extends Mock implements ProcessDownloadQueueUseCase {}

class MockSyncNotificationService extends Mock implements SyncNotificationService {}

class MockSyncLogService extends Mock implements SyncLogService {}

void main() {
  late MockProcessDownloadQueueUseCase processQueue;
  late MockDownloadQueueRepository queue;
  late MockDownloadScheduler scheduler;
  late MockSyncNotificationService notifications;
  late SyncLock lock;
  late BackgroundDownloadService service;

  const progress = DownloadProgress(total: 3, saved: 2, failed: 1, bytesTotal: 30, bytesSaved: 20);

  setUpAll(() => registerFallbackValue(Duration.zero));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    lock = SyncLock(sharedPreferences: await SharedPreferences.getInstance());
    processQueue = MockProcessDownloadQueueUseCase();
    queue = MockDownloadQueueRepository();
    scheduler = MockDownloadScheduler();
    notifications = MockSyncNotificationService();
    final log = MockSyncLogService();
    service = BackgroundDownloadService(processQueue: processQueue, queue: queue, scheduler: scheduler, lock: lock,
        notifications: notifications, log: log);

    when(() => queue.pending(limit: 1)).thenAnswer((_) async => const [QueuedDownload(fileId: '1', sizeBytes: 1)]);
    when(() => queue.progress()).thenAnswer((_) async => progress);
    when(() => scheduler.schedule()).thenAnswer((_) async {});
    when(() => notifications.showDownloadProgress(saved: any(named: 'saved'), total: any(named: 'total')))
        .thenAnswer((_) async {});
    when(() => notifications.showDownloadFinished(saved: any(named: 'saved'), failed: any(named: 'failed')))
        .thenAnswer((_) async {});
    when(() => notifications.hideForegroundNotification()).thenAnswer((_) async {});
    when(() => processQueue(budget: any(named: 'budget'), onFileDone: any(named: 'onFileDone')))
        .thenAnswer((_) async => const DownloadRunResult(saved: 2, failed: 1, hasPending: false));
  });

  tearDown(() => lock.release());

  group('BackgroundDownloadService', () {
    test('should save the queue holding the lock and notify the end', () async {
      var lockHeldWhileSaving = false;
      when(() => processQueue(budget: any(named: 'budget'), onFileDone: any(named: 'onFileDone')))
          .thenAnswer((_) async {
        lockHeldWhileSaving = (await lock.check()).isHeld;
        return const DownloadRunResult(saved: 2, failed: 1, hasPending: false);
      });

      final result = await service.execute();

      expect(result, isTrue);
      expect(lockHeldWhileSaving, isTrue);
      expect((await lock.check()).isHeld, isFalse);
      verify(() => processQueue(budget: BackgroundDownloadService.budget, onFileDone: any(named: 'onFileDone')))
          .called(1);
      verify(() => notifications.showDownloadProgress(saved: 3, total: 3)).called(1);
      verify(() => notifications.showDownloadFinished(saved: 2, failed: 1)).called(1);
      verify(() => notifications.hideForegroundNotification()).called(1);
      verifyNever(() => scheduler.schedule());
    });

    test('should append another run when files remain', () async {
      when(() => processQueue(budget: any(named: 'budget'), onFileDone: any(named: 'onFileDone')))
          .thenAnswer((_) async => const DownloadRunResult(saved: 5, failed: 0, hasPending: true));

      expect(await service.execute(), isTrue);

      verify(() => scheduler.schedule()).called(1);
      verifyNever(() => notifications.showDownloadFinished(saved: any(named: 'saved'), failed: any(named: 'failed')));
    });

    test('should wait for a sync that holds the lock', () async {
      await lock.acquire();

      expect(await service.execute(), isFalse);

      verifyNever(() => processQueue(budget: any(named: 'budget'), onFileDone: any(named: 'onFileDone')));
    });

    test('should end at once when nothing is queued', () async {
      when(() => queue.pending(limit: 1)).thenAnswer((_) async => []);

      expect(await service.execute(), isTrue);

      verifyNever(() => processQueue(budget: any(named: 'budget'), onFileDone: any(named: 'onFileDone')));
      expect((await lock.check()).isHeld, isFalse);
    });

    test('should release the lock and hide the notification when saving fails', () async {
      when(() => processQueue(budget: any(named: 'budget'), onFileDone: any(named: 'onFileDone')))
          .thenThrow(Exception('crash'));

      await expectLater(service.execute(), throwsA(isA<Exception>()));

      expect((await lock.check()).isHeld, isFalse);
      verify(() => notifications.hideForegroundNotification()).called(1);
    });
  });
}
