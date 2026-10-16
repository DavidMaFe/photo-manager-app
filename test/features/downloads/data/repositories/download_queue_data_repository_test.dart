import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/download_queue_local_data_source.dart';
import 'package:photo_manager_app/features/downloads/data/repositories/download_queue_data_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';

class MockDownloadQueueLocalDataSource extends Mock implements DownloadQueueLocalDataSource {}

void main() {
  late MockDownloadQueueLocalDataSource dataSource;
  late DownloadQueueDataRepository repository;

  setUp(() {
    dataSource = MockDownloadQueueLocalDataSource();
    repository = DownloadQueueDataRepository(localDataSource: dataSource);
    when(() => dataSource.setState(any(), any())).thenAnswer((_) async {});
  });

  group('DownloadQueueDataRepository', () {
    test('should mark saved and failed files with their state', () async {
      await repository.markSaved('1');
      await repository.markFailed('2');

      verify(() => dataSource.setState('1', DownloadQueueLocalDataSourceImpl.stateSaved)).called(1);
      verify(() => dataSource.setState('2', DownloadQueueLocalDataSourceImpl.stateFailed)).called(1);
    });

    test('should pass the rest of the calls to the table', () async {
      const queued = [QueuedDownload(fileId: '1', sizeBytes: 1)];
      when(() => dataSource.enqueue(queued)).thenAnswer((_) async {});
      when(() => dataSource.pending(5)).thenAnswer((_) async => queued);
      when(() => dataSource.isPending('1')).thenAnswer((_) async => true);
      when(() => dataSource.savedIds()).thenAnswer((_) async => ['9']);
      when(() => dataSource.progress()).thenAnswer((_) async => DownloadProgress.empty);
      when(() => dataSource.deletePending()).thenAnswer((_) async {});

      await repository.enqueue(queued);
      expect(await repository.pending(limit: 5), queued);
      expect(await repository.isPending('1'), isTrue);
      expect(await repository.savedIds(), ['9']);
      expect(await repository.progress(), DownloadProgress.empty);
      await repository.cancelPending();

      verify(() => dataSource.enqueue(queued)).called(1);
      verify(() => dataSource.deletePending()).called(1);
    });
  });
}
