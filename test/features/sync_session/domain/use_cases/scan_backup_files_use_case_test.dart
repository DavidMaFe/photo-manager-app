import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/gallery_scan.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/backup_progress_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/gallery_media_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/scan_backup_files_use_case.dart';

import '../../../../fixtures/test_data.dart';

class MockGalleryMediaSource extends Mock implements GalleryMediaSource {}

class MockBackupProgressRepository extends Mock implements BackupProgressRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

SyncFile file(String localId) => SyncFile(localId: localId, devicePath: '/storage/$localId.jpg', hash: 'hash-$localId',
    fileName: '$localId.jpg', sizeBytes: 100, capturedAt: DateTime(2019, 7, 14), mimeType: 'image/jpeg');

void main() {
  final now = DateTime(2026, 10, 23, 12);
  final user = TestUsers.johnDoe;
  late MockGalleryMediaSource gallery;
  late MockBackupProgressRepository progress;
  late MockAuthRepository authRepository;
  late ScanBackupFilesUseCase useCase;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(<String>{});
  });

  setUp(() {
    gallery = MockGalleryMediaSource();
    progress = MockBackupProgressRepository();
    authRepository = MockAuthRepository();
    useCase = ScanBackupFilesUseCase(gallery, progress, authRepository, now: () => now);

    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => user);
    when(() => progress.watermark(user.id)).thenAnswer((_) async => null);
    when(() => progress.pending(user.id)).thenAnswer((_) async => {});
    when(() => gallery.addedSince(any(), checkPermission: any(named: 'checkPermission')))
        .thenAnswer((_) async => GalleryScan.empty);
    when(() => gallery.albumsOf(any())).thenAnswer((_) async => {});
  });

  DateTime? lookedSince() =>
      verify(() => gallery.addedSince(captureAny(), checkPermission: any(named: 'checkPermission'))).captured.single
          as DateTime?;

  group('ScanBackupFilesUseCase', () {
    group('since when it looks', () {
      test('should look from where the last completed backup started, with a margin', () async {
        when(() => progress.watermark(user.id)).thenAnswer((_) async => DateTime(2026, 10, 22, 3));

        await useCase(lastCompletedAt: DateTime(2026, 10, 22, 3, 20));

        expect(lookedSince(), DateTime(2026, 10, 22, 3).subtract(ScanBackupFilesUseCase.margin));
      });

      test('should look from the last completed backup of the server the first time after the update', () async {
        await useCase(lastCompletedAt: DateTime(2026, 10, 22, 3, 20));

        expect(lookedSince(), DateTime(2026, 10, 22, 3, 20).subtract(ScanBackupFilesUseCase.margin));
      });

      test('should look at every file at the first backup', () async {
        await useCase();

        expect(lookedSince(), isNull);
      });

      test('should not ask for the permission in the background', () async {
        await useCase(checkPermission: false);

        verify(() => gallery.addedSince(null, checkPermission: false)).called(1);
      });
    });

    group('files', () {
      test('should take a photo with an old capture date that arrived after the last backup', () async {
        // Given: A photo of 2019 copied to the device today: the gallery finds it by its date of addition
        when(() => gallery.addedSince(any(), checkPermission: any(named: 'checkPermission')))
            .thenAnswer((_) async => GalleryScan(files: [file('trip-2019')]));

        // When
        final scan = await useCase(lastCompletedAt: DateTime(2026, 10, 22));

        // Then
        expect(scan.files.map((f) => f.localId), ['trip-2019']);
        expect(scan.files.single.capturedAt, DateTime(2019, 7, 14));
      });

      test('should try again the files the previous backups skipped, after the new ones', () async {
        when(() => gallery.addedSince(any(), checkPermission: any(named: 'checkPermission')))
            .thenAnswer((_) async => GalleryScan(files: [file('new')]));
        when(() => progress.pending(user.id)).thenAnswer((_) async => {'did-not-fit', 'new'});
        when(() => gallery.withIds({'did-not-fit'})).thenAnswer((_) async => GalleryScan(files: [file('did-not-fit')]));

        final scan = await useCase();

        expect(scan.files.map((f) => f.localId), ['new', 'did-not-fit']);
      });

      test('should forget the pending files that are no longer in the gallery', () async {
        when(() => progress.pending(user.id)).thenAnswer((_) async => {'deleted'});
        when(() => gallery.withIds({'deleted'})).thenAnswer((_) async => const GalleryScan(files: [], missingIds: {'deleted'}));

        final scan = await useCase();

        expect(scan.files, isEmpty);
        expect(scan.unreadableIds, isEmpty);
      });

      test('should keep the files that could not be read to try them again', () async {
        when(() => gallery.addedSince(any(), checkPermission: any(named: 'checkPermission')))
            .thenAnswer((_) async => const GalleryScan(files: [], unreadableIds: {'cloud-only'}));

        final scan = await useCase();

        expect(scan.unreadableIds, {'cloud-only'});
      });

      test('should give each file its album of the gallery', () async {
        when(() => gallery.addedSince(any(), checkPermission: any(named: 'checkPermission')))
            .thenAnswer((_) async => GalleryScan(files: [file('in-album'), file('loose')]));
        when(() => gallery.albumsOf({'in-album', 'loose'})).thenAnswer((_) async => {'in-album': '747804901'});

        final scan = await useCase();

        expect(scan.files.first.localAlbumId, '747804901');
        expect(scan.files.last.localAlbumId, isNull);
      });

      test('should not read the albums when there is nothing to back up', () async {
        await useCase();

        verifyNever(() => gallery.albumsOf(any()));
      });
    });

    group('account', () {
      test('should say when it started and the account', () async {
        final scan = await useCase();

        expect(scan.startedAt, now);
        expect(scan.userId, user.id);
      });

      test('should look from the server and remember nothing when the user is not known', () async {
        when(() => authRepository.getCurrentUser()).thenAnswer((_) async => null);

        final scan = await useCase(lastCompletedAt: DateTime(2026, 10, 22));

        expect(scan.userId, isNull);
        expect(lookedSince(), DateTime(2026, 10, 22).subtract(ScanBackupFilesUseCase.margin));
        verifyNever(() => progress.watermark(any()));
        verifyNever(() => progress.pending(any()));
      });
    });
  });
}
