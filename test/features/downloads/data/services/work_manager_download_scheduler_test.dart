import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/data/services/work_manager_download_scheduler.dart';
import 'package:workmanager/workmanager.dart';

class MockWorkmanager extends Mock implements Workmanager {}

void main() {
  late MockWorkmanager workmanager;
  late WorkManagerDownloadScheduler scheduler;

  setUpAll(() {
    registerFallbackValue(ExistingWorkPolicy.keep);
    registerFallbackValue(Constraints(networkType: NetworkType.connected));
  });

  setUp(() {
    workmanager = MockWorkmanager();
    scheduler = WorkManagerDownloadScheduler(workmanager: workmanager);
    when(() => workmanager.registerOneOffTask(any(), any(),
        constraints: any(named: 'constraints'),
        existingWorkPolicy: any(named: 'existingWorkPolicy'),
        tag: any(named: 'tag'))).thenAnswer((_) async {});
    when(() => workmanager.cancelByUniqueName(any())).thenAnswer((_) async {});
  });

  group('WorkManagerDownloadScheduler', () {
    test('should append a run of the download task that needs network', () async {
      await scheduler.schedule();

      final captured = verify(() => workmanager.registerOneOffTask(
            WorkManagerDownloadScheduler.taskName,
            WorkManagerDownloadScheduler.taskName,
            constraints: captureAny(named: 'constraints'),
            existingWorkPolicy: ExistingWorkPolicy.append,
            tag: 'download',
          )).captured;
      expect((captured.single as Constraints).networkType, NetworkType.connected);
    });

    test('should cancel the task', () async {
      await scheduler.cancel();

      verify(() => workmanager.cancelByUniqueName(WorkManagerDownloadScheduler.taskName)).called(1);
    });
  });
}
