import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/missing_on_device.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/plan_download_use_case.dart';

import '../../downloads_mocks.dart';

void main() {
  late MockComputeMissingOnDeviceUseCase computeMissing;
  late MockDeviceGalleryRepository gallery;
  late PlanDownloadUseCase useCase;

  setUp(() {
    computeMissing = MockComputeMissingOnDeviceUseCase();
    gallery = MockDeviceGalleryRepository();
    useCase = PlanDownloadUseCase(computeMissing, gallery);
    when(() => gallery.isSupported()).thenAnswer((_) async => true);
    when(() => gallery.storage()).thenAnswer((_) async => DownloadsTestData.roomyStorage);
  });

  group('PlanDownloadUseCase', () {
    test('should plan every missing file of the account with the free space', () async {
      when(() => computeMissing()).thenAnswer((_) async => const MissingOnDevice(
          missing: [DownloadsTestData.video, DownloadsTestData.otherPhoto], onDevice: [DownloadsTestData.photo]));

      final plan = await useCase();

      expect(plan.toDownload, [DownloadsTestData.video, DownloadsTestData.otherPhoto]);
      expect(plan.alreadyOnDevice, 1);
      expect(plan.storage, DownloadsTestData.roomyStorage);
    });

    test('should keep only the chosen files', () async {
      when(() => computeMissing()).thenAnswer((_) async => const MissingOnDevice(
          missing: [DownloadsTestData.video, DownloadsTestData.otherPhoto], onDevice: [DownloadsTestData.photo]));

      final plan = await useCase(fileIds: {'1', '2'});

      expect(plan.toDownload, [DownloadsTestData.video]);
      expect(plan.alreadyOnDevice, 1);
    });

    test('should plan an album with its subalbums', () async {
      when(() => computeMissing(folderId: '10', includeSubfolders: true)).thenAnswer(
          (_) async => const MissingOnDevice(missing: [DownloadsTestData.photo], onDevice: []));

      final plan = await useCase(folderId: '10', includeSubfolders: true);

      expect(plan.toDownload, [DownloadsTestData.photo]);
      expect(plan.alreadyOnDevice, 0);
    });

    test('should throw DeviceMediaUnsupportedFailure when the device cannot save into its gallery', () async {
      when(() => gallery.isSupported()).thenAnswer((_) async => false);

      expect(useCase(), throwsA(isA<DeviceMediaUnsupportedFailure>()));
      verifyNever(() => computeMissing());
    });
  });
}
