import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/files_within_plan.dart';

import '../../../../helpers/plan_test_providers.dart';

void main() {
  SyncFile file(String name, String mimeType, int sizeBytes) => SyncFile(
        localId: name,
        devicePath: '/storage/$name',
        hash: name,
        fileName: name,
        sizeBytes: sizeBytes,
        capturedAt: DateTime(2026, 10, 18),
        mimeType: mimeType,
      );

  final photo = file('photo.jpg', 'image/jpeg', 300 * testMib);
  final shortVideo = file('short.mp4', 'video/mp4', 50 * testMib);
  final longVideo = file('long.mp4', 'video/mp4', 500 * testMib);

  group('filesWithinPlan', () {
    test('should leave out the videos over the limit of the free plan', () {
      expect(filesWithinPlan([photo, shortVideo, longVideo], TestPlans.free), [photo, shortVideo]);
    });

    test('should keep the videos that fit in a paid plan', () {
      expect(filesWithinPlan([shortVideo, longVideo], TestPlans.plus100), [shortVideo, longVideo]);
    });

    test('should keep every file when the plan could not be read', () {
      expect(filesWithinPlan([longVideo], null), [longVideo]);
    });
  });
}
