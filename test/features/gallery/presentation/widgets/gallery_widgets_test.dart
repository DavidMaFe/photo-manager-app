import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/backup_status_chip.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/file_filter_label.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/gallery_top_bar.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/pending_review_card.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/l10n/app_localizations_en.dart';
import 'package:photo_manager_app/l10n/app_localizations_es.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockSyncSessionBloc extends Mock implements SyncSessionBloc {}

void main() {
  group('BackupStatusChip', () {
    late MockSyncSessionBloc bloc;

    setUp(() {
      bloc = MockSyncSessionBloc();
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => bloc.close()).thenAnswer((_) async {});
    });

    Future<StatusChip> pumpWith(WidgetTester tester, SyncSessionState state, {VoidCallback? onTap}) async {
      when(() => bloc.state).thenReturn(state);
      await tester.pumpWidget(makeTestableWidgetWithBloc<SyncSessionBloc>(
        bloc: bloc,
        child: Scaffold(body: Center(child: BackupStatusChip(onTap: onTap))),
      ));
      return tester.widget<StatusChip>(find.byType(StatusChip));
    }

    testWidgets('should show up to date when idle', (tester) async {
      final chip = await pumpWith(tester, const SyncSessionInitial());
      expect(chip.label, 'Up to date');
      expect(chip.variant, StatusChipVariant.safe);
    });

    testWidgets('should show the upload percentage while uploading', (tester) async {
      final chip = await pumpWith(tester, const SyncSessionUploading(uploadCount: 45, totalCount: 100));
      expect(chip.label, 'Backing up 45%');
      expect(chip.variant, StatusChipVariant.accent);
    });

    testWidgets('should show 0% while preparing the backup', (tester) async {
      final chip = await pumpWith(tester, const SyncSessionFetchingFiles());
      expect(chip.label, 'Backing up 0%');
    });

    testWidgets('should show the failure state on error', (tester) async {
      final chip = await pumpWith(tester, const SyncSessionError(NetworkFailure()));
      expect(chip.label, 'Backup failed');
      expect(chip.variant, StatusChipVariant.danger);
    });

    testWidgets('should forward taps', (tester) async {
      var taps = 0;
      await pumpWith(tester, const SyncSessionInitial(), onTap: () => taps++);
      await tester.tap(find.byType(StatusChip));
      expect(taps, 1);
    });
  });

  group('GalleryTopBar', () {
    testWidgets('should show the title and actions outside selection mode', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: GalleryTopBar(actions: [Text('action')]),
      )));

      // Assert
      expect(find.text('Photos'), findsOneWidget);
      expect(find.text('action'), findsOneWidget);
    });

    testWidgets('should offer "All" until every file is selected', (tester) async {
      // Arrange
      var selectAll = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: GalleryTopBar(isSelectionMode: true, selectedCount: 1, onSelectAll: () => selectAll++),
      )));

      // Act
      await tester.tap(find.text('All'));

      // Assert
      expect(find.text('1 selected'), findsOneWidget);
      expect(selectAll, 1);
    });

    testWidgets('should offer "None" when everything is selected', (tester) async {
      // Arrange
      var deselect = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: GalleryTopBar(
          isSelectionMode: true,
          selectedCount: 5,
          areAllFilesSelected: true,
          onDeselectAll: () => deselect++,
        ),
      )));

      // Act
      await tester.tap(find.text('None'));

      // Assert
      expect(deselect, 1);
    });
  });

  group('PendingReviewCard', () {
    testWidgets('should render the count and call onReview', (tester) async {
      // Arrange
      var reviews = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: PendingReviewCard(pendingCount: 1, onReview: () => reviews++),
      )));

      // Act
      await tester.tap(find.text('Review'));

      // Assert
      expect(find.text('1 item to review'), findsOneWidget);
      expect(find.text('Decide whether to keep them or free up space on your phone'), findsOneWidget);
      expect(reviews, 1);
    });

    testWidgets('should render nothing without pending files', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: PendingReviewCard(pendingCount: 0, onReview: () {}),
      )));

      // Assert
      expect(find.text('Review'), findsNothing);
    });
  });

  group('FileFilterLabel', () {
    test('should localize every filter', () {
      final es = AppLocalizationsEs();
      expect(FileFilter.values.map((f) => f.label(es)), ['Todo', 'Fotos', 'Vídeos', 'Por revisar']);
      final en = AppLocalizationsEn();
      expect(FileFilter.values.map((f) => f.label(en)), ['All', 'Photos', 'Videos', 'To review']);
    });
  });
}
