import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/downloadable_file.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/download_queue_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/file_mapping_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/server_files_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/share_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/services/download_scheduler.dart';
import 'package:photo_manager_app/features/downloads/domain/services/original_content_reader.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/compute_missing_on_device_use_case.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/save_original_to_gallery_use_case.dart';

class MockServerFilesRepository extends Mock implements ServerFilesRepository {}

class MockFileMappingRepository extends Mock implements FileMappingRepository {}

class MockDeviceGalleryRepository extends Mock implements DeviceGalleryRepository {}

class MockDownloadQueueRepository extends Mock implements DownloadQueueRepository {}

class MockDownloadScheduler extends Mock implements DownloadScheduler {}

class MockShareRepository extends Mock implements ShareRepository {}

class MockOriginalContentReader extends Mock implements OriginalContentReader {}

class MockComputeMissingOnDeviceUseCase extends Mock implements ComputeMissingOnDeviceUseCase {}

class MockSaveOriginalToGalleryUseCase extends Mock implements SaveOriginalToGalleryUseCase {}

class FakeDownloadableFile extends Fake implements DownloadableFile {}

/// Test data of the downloads.
abstract final class DownloadsTestData {
  static const RemoteMediaFile photo = RemoteMediaFile(id: '1', type: FileType.image, sizeBytes: 3000000, folderId: '10');
  static const RemoteMediaFile video = RemoteMediaFile(id: '2', type: FileType.video, sizeBytes: 50000000);
  static const RemoteMediaFile otherPhoto = RemoteMediaFile(id: '3', type: FileType.image, sizeBytes: 2000000);

  static const DeviceStorage roomyStorage = DeviceStorage(freeBytes: 100000000000, totalBytes: 256000000000);
  static const DeviceStorage fullStorage = DeviceStorage(freeBytes: 100000000, totalBytes: 256000000000);

  static final DownloadableFile downloadablePhoto =
      DownloadableFile(id: '1', type: FileType.image, capturedAt: DateTime(2024, 8, 3, 10, 42));
  static final DownloadableFile downloadableVideo =
      DownloadableFile(id: '2', type: FileType.video, capturedAt: DateTime(2024, 8, 4, 18, 3));

  static DownloadPlan plan(List<RemoteMediaFile> files, {DeviceStorage storage = roomyStorage, int onDevice = 0}) =>
      DownloadPlan(toDownload: files, alreadyOnDevice: onDevice, storage: storage);
}
