import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/backup_scan.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/backup_progress_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_backup_scan_use_case.dart';

class MockBackupProgressRepository extends Mock implements BackupProgressRepository {}

void main() {
  final startedAt = DateTime(2026, 10, 23, 12);
  late MockBackupProgressRepository progress;
  late CompleteBackupScanUseCase useCase;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(<String>{});
  });

  setUp(() {
    progress = MockBackupProgressRepository();
    useCase = CompleteBackupScanUseCase(progress);
    when(() => progress.replacePending(any(), any())).thenAnswer((_) async {});
    when(() => progress.saveWatermark(any(), any())).thenAnswer((_) async {});
  });

  group('CompleteBackupScanUseCase', () {
    test('should look from where this backup started and try again what it skipped and could not read', () async {
      final scan = BackupScan(files: const [], startedAt: startedAt, userId: 'user-1', unreadableIds: {'cloud'});

      await useCase(scan, {'did-not-fit'});

      verify(() => progress.replacePending('user-1', {'did-not-fit', 'cloud'})).called(1);
      verify(() => progress.saveWatermark('user-1', startedAt)).called(1);
    });

    test('should leave nothing pending when everything was backed up', () async {
      await useCase(BackupScan(files: const [], startedAt: startedAt, userId: 'user-1'), {});

      verify(() => progress.replacePending('user-1', {})).called(1);
    });

    test('should remember nothing without the account', () async {
      await useCase(BackupScan(files: const [], startedAt: startedAt), {'a'});

      verifyNever(() => progress.replacePending(any(), any()));
      verifyNever(() => progress.saveWatermark(any(), any()));
    });
  });
}
