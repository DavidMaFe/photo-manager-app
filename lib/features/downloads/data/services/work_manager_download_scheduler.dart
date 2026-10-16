import 'package:photo_manager_app/features/downloads/domain/services/download_scheduler.dart';
import 'package:workmanager/workmanager.dart';

/// [DownloadScheduler] on WorkManager: one chain of tasks [taskName]. Each run saves files for a while and, if files
/// remain, appends the next run (WorkManager stops a task after 10 minutes).
class WorkManagerDownloadScheduler implements DownloadScheduler {
  static const String taskName = 'background_download_task';
  static const String _tag = 'download';

  final Workmanager workmanager;

  WorkManagerDownloadScheduler({Workmanager? workmanager}) : workmanager = workmanager ?? Workmanager();

  @override
  Future<void> schedule() => workmanager.registerOneOffTask(
        taskName,
        taskName,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.append,
        tag: _tag,
      );

  @override
  Future<void> cancel() => workmanager.cancelByUniqueName(taskName);
}
