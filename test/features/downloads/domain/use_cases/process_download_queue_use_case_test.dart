import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/process_download_queue_use_case.dart';

import '../../downloads_mocks.dart';

void main() {
  late MockDownloadQueueRepository queue;
  late MockServerFilesRepository serverFiles;
  late MockSaveOriginalToGalleryUseCase saveOriginal;
  late List<QueuedDownload> pending;
  late DateTime now;

  ProcessDownloadQueueUseCase build() =>
      ProcessDownloadQueueUseCase(queue, serverFiles, saveOriginal, clock: () => now);

  setUpAll(() => registerFallbackValue(FakeDownloadableFile()));

  setUp(() {
    queue = MockDownloadQueueRepository();
    serverFiles = MockServerFilesRepository();
    saveOriginal = MockSaveOriginalToGalleryUseCase();
    now = DateTime(2026, 10, 17, 10);
    pending = [
      const QueuedDownload(fileId: '1', album: 'Trip', sizeBytes: 3),
      const QueuedDownload(fileId: '2', sizeBytes: 5),
    ];
    // The queue drops the files as they are marked
    when(() => queue.pending(limit: any(named: 'limit'))).thenAnswer((_) async => List.of(pending));
    when(() => queue.isPending(any())).thenAnswer((i) async => pending.any((q) => q.fileId == i.positionalArguments[0]));
    when(() => queue.markSaved(any())).thenAnswer((i) async => pending.removeWhere((q) => q.fileId == i.positionalArguments[0]));
    when(() => queue.markFailed(any())).thenAnswer((i) async => pending.removeWhere((q) => q.fileId == i.positionalArguments[0]));
    when(() => serverFiles.downloadable(any())).thenAnswer(
        (_) async => [DownloadsTestData.downloadablePhoto, DownloadsTestData.downloadableVideo]);
    when(() => serverFiles.markOnDevice(any())).thenAnswer((_) async {});
    when(() => saveOriginal(any(), album: any(named: 'album'))).thenAnswer((_) async => 'local');
  });

  group('ProcessDownloadQueueUseCase', () {
    test('should save every queued file into its album and report them to the server', () async {
      var done = 0;

      final result = await build()(budget: const Duration(minutes: 8), onFileDone: () => done++);

      expect(result.saved, 2);
      expect(result.failed, 0);
      expect(result.hasPending, isFalse);
      expect(done, 2);
      verify(() => saveOriginal(DownloadsTestData.downloadablePhoto, album: 'Trip')).called(1);
      verify(() => saveOriginal(DownloadsTestData.downloadableVideo, album: null)).called(1);
      verify(() => serverFiles.markOnDevice(['1', '2'])).called(1);
    });

    test('should mark a failed file and go on with the rest', () async {
      when(() => saveOriginal(DownloadsTestData.downloadablePhoto, album: 'Trip')).thenThrow(Exception('io'));

      final result = await build()(budget: const Duration(minutes: 8));

      expect(result.saved, 1);
      expect(result.failed, 1);
      verify(() => queue.markFailed('1')).called(1);
      verify(() => queue.markSaved('2')).called(1);
      verify(() => serverFiles.markOnDevice(['2'])).called(1);
    });

    test('should fail the files the server no longer has (trashed since they were queued)', () async {
      when(() => serverFiles.downloadable(any())).thenAnswer((_) async => [DownloadsTestData.downloadableVideo]);

      final result = await build()(budget: const Duration(minutes: 8));

      expect(result.failed, 1);
      verify(() => queue.markFailed('1')).called(1);
      verifyNever(() => saveOriginal(DownloadsTestData.downloadablePhoto, album: any(named: 'album')));
    });

    test('should skip the files cancelled while the batch runs', () async {
      when(() => saveOriginal(DownloadsTestData.downloadablePhoto, album: 'Trip')).thenAnswer((_) async {
        pending.clear();
        return 'local';
      });

      final result = await build()(budget: const Duration(minutes: 8));

      expect(result.saved, 1);
      verifyNever(() => saveOriginal(DownloadsTestData.downloadableVideo, album: any(named: 'album')));
    });

    test('should stop at the time limit and say files remain', () async {
      when(() => saveOriginal(DownloadsTestData.downloadablePhoto, album: 'Trip')).thenAnswer((_) async {
        now = now.add(const Duration(minutes: 9));
        return 'local';
      });

      final result = await build()(budget: const Duration(minutes: 8));

      expect(result.saved, 1);
      expect(result.hasPending, isTrue);
      verify(() => serverFiles.markOnDevice(['1'])).called(1);
    });

    test('should keep the files saved when reporting them to the server fails', () async {
      when(() => serverFiles.markOnDevice(any())).thenThrow(Exception('offline'));

      final result = await build()(budget: const Duration(minutes: 8));

      expect(result.saved, 2);
      expect(result.hasPending, isFalse);
    });

    test('should end at once when nothing is queued', () async {
      pending.clear();

      final result = await build()(budget: const Duration(minutes: 8));

      expect(result.saved + result.failed, 0);
      verifyNever(() => serverFiles.downloadable(any()));
    });
  });
}
