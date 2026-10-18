import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/cancel_download_use_case.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/start_download_use_case.dart';

import '../../downloads_mocks.dart';

void main() {
  late MockDownloadQueueRepository queue;
  late MockDownloadScheduler scheduler;

  setUp(() {
    queue = MockDownloadQueueRepository();
    scheduler = MockDownloadScheduler();
    when(() => queue.enqueue(any())).thenAnswer((_) async {});
    when(() => queue.cancelPending()).thenAnswer((_) async {});
    when(() => scheduler.schedule()).thenAnswer((_) async {});
    when(() => scheduler.cancel()).thenAnswer((_) async {});
  });

  group('StartDownloadUseCase', () {
    test('should queue the files into the album and start the background task', () async {
      final useCase = StartDownloadUseCase(queue, scheduler);

      await useCase(DownloadsTestData.plan([DownloadsTestData.photo, DownloadsTestData.video]), album: 'Trip');

      verify(() => queue.enqueue(const [
            QueuedDownload(fileId: '1', album: 'Trip', sizeBytes: 3000000),
            QueuedDownload(fileId: '2', album: 'Trip', sizeBytes: 50000000),
          ])).called(1);
      verify(() => scheduler.schedule()).called(1);
    });

    test('should do nothing when every file is already on the device', () async {
      await StartDownloadUseCase(queue, scheduler)(DownloadsTestData.plan([], onDevice: 3));

      verifyNever(() => queue.enqueue(any()));
      verifyNever(() => scheduler.schedule());
    });

    test('should throw NotEnoughSpaceFailure when the files do not fit', () async {
      final plan = DownloadsTestData.plan([DownloadsTestData.video], storage: DownloadsTestData.fullStorage);

      await expectLater(StartDownloadUseCase(queue, scheduler)(plan), throwsA(isA<NotEnoughSpaceFailure>()));
      verifyNever(() => queue.enqueue(any()));
    });
  });

  group('CancelDownloadUseCase', () {
    test('should empty the pending files and cancel the background task', () async {
      await CancelDownloadUseCase(queue, scheduler)();

      verify(() => queue.cancelPending()).called(1);
      verify(() => scheduler.cancel()).called(1);
    });
  });
}
