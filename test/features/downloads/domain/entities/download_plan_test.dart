import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';

import '../../downloads_mocks.dart';

void main() {
  group('DownloadPlan', () {
    test('should add up the size of the files to download', () {
      final plan = DownloadsTestData.plan([DownloadsTestData.photo, DownloadsTestData.video]);

      expect(plan.bytesToDownload, 53000000);
      expect(plan.isEmpty, isFalse);
    });

    test('should fit when the free space keeps the reserve after the download', () {
      final free = DownloadsTestData.photo.sizeBytes + DownloadPlan.reservedBytes;

      expect(DownloadsTestData.plan([DownloadsTestData.photo],
          storage: DeviceStorage(freeBytes: free, totalBytes: free)).fits, isTrue);
      expect(DownloadsTestData.plan([DownloadsTestData.photo],
          storage: DeviceStorage(freeBytes: free - 1, totalBytes: free)).fits, isFalse);
    });
  });

  group('DownloadProgress', () {
    test('should be running while files remain', () {
      const progress = DownloadProgress(total: 3, saved: 1, failed: 1, bytesTotal: 30, bytesSaved: 10);

      expect(progress.remaining, 1);
      expect(progress.isRunning, isTrue);
      expect(progress.isEmpty, isFalse);
    });

    test('should not be running when every file was saved or failed', () {
      const progress = DownloadProgress(total: 2, saved: 1, failed: 1, bytesTotal: 20, bytesSaved: 10);

      expect(progress.isRunning, isFalse);
      expect(DownloadProgress.empty.isEmpty, isTrue);
    });
  });
}
