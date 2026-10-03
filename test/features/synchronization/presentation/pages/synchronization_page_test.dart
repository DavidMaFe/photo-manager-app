import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_bloc.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/pages/synchronization_page.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_list_item.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_status_card.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockSynchronizationBloc extends Mock implements SynchronizationBloc {}

class MockSyncConfigBloc extends Mock implements SyncConfigBloc {}

class MockSyncSessionBloc extends Mock implements SyncSessionBloc {}

class FakeSyncSessionEvent extends Fake implements SyncSessionEvent {}

void main() {
  late MockSynchronizationBloc syncBloc;
  late MockSyncConfigBloc configBloc;
  late MockSyncSessionBloc sessionBloc;
  late StreamController<SyncSessionState> sessionStates;
  late DateTime now;

  setUpAll(() {
    registerFallbackValue(FakeSyncSessionEvent());
  });

  setUp(() {
    now = DateTime(2026, 10, 3, 12);
    sessionStates = StreamController<SyncSessionState>.broadcast();
    sessionBloc = MockSyncSessionBloc();
    when(() => sessionBloc.stream).thenAnswer((_) => sessionStates.stream);
    when(() => sessionBloc.state).thenReturn(const SyncSessionInitial());
    syncBloc = MockSynchronizationBloc();
    when(() => syncBloc.stream).thenAnswer((_) => const Stream.empty());
    configBloc = MockSyncConfigBloc();
    when(() => configBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => configBloc.state).thenReturn(SyncConfigLoaded(TestSyncConfigs.dailySync));
  });

  Synchronization session(String id, SynchronizationStatus status) => Synchronization(
        id: id,
        startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: status,
        totalFiles: 10,
        uploadedFiles: 10,
        failedFiles: 0,
      );

  tearDown(() => sessionStates.close());

  Future<void> pump(WidgetTester tester, SynchronizationState state, {bool background = true}) async {
    setUpCustomScreenSize(tester, 390, 1400);
    when(() => syncBloc.state).thenReturn(state);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<SynchronizationBloc>.value(value: syncBloc),
        BlocProvider<SyncConfigBloc>.value(value: configBloc),
        BlocProvider<SyncSessionBloc>.value(value: sessionBloc),
      ],
      child: SynchronizationPage(backgroundCheck: () async => background, clock: () => now),
    ));
    await tester.pump();
  }

  /// Emits a backup state as the real bloc would.
  Future<void> emitSession(WidgetTester tester, SyncSessionState state) async {
    when(() => sessionBloc.state).thenReturn(state);
    sessionStates.add(state);
    await tester.pump();
  }

  SynchronizationsLoaded loaded(int count, {bool hasMore = false}) => SynchronizationsLoaded(
        sessions: [for (var i = 0; i < count; i++) session('$i', SynchronizationStatus.completed)],
        hasMore: hasMore,
        currentPage: 0,
      );

  group('SynchronizationPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the Backup header, status card and activity', (tester) async {
      // Arrange & Act
      await pump(tester, SynchronizationsLoaded(
        sessions: [session('1', SynchronizationStatus.completed), session('2', SynchronizationStatus.failed)],
        hasMore: false,
        currentPage: 0,
      ));

      // Assert
      expect(find.byType(ScreenHeader), findsOneWidget);
      expect(find.text('Backup'), findsOneWidget);
      expect(find.byType(SynchronizationStatusCard), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.byType(SynchronizationListItem), findsNWidgets(2));
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('should base the status card on the latest session', (tester) async {
      // Arrange & Act
      await pump(tester, SynchronizationsLoaded(
        sessions: [session('1', SynchronizationStatus.completed), session('2', SynchronizationStatus.failed)],
        hasMore: false,
        currentPage: 0,
      ));

      // Assert
      final card = tester.widget<SynchronizationStatusCard>(find.byType(SynchronizationStatusCard));
      expect(card.latestSync!.id, '1');
      expect(card.config, TestSyncConfigs.dailySync);
    });

    testWidgets('should hide the activity section without sessions', (tester) async {
      // Arrange & Act
      await pump(tester, const SynchronizationsLoaded(sessions: [], hasMore: false, currentPage: 0));

      // Assert
      expect(find.text('Activity'), findsNothing);
      expect(find.text("You haven't backed up yet"), findsOneWidget);
    });

    testWidgets('should hide the condition pills until the config loads', (tester) async {
      // Arrange
      when(() => configBloc.state).thenReturn(SyncConfigLoading());

      // Act
      await pump(tester, const SynchronizationsLoaded(sessions: [], hasMore: false, currentPage: 0));

      // Assert
      expect(find.byType(BackupConditionsRow), findsNothing);
    });

    // ==================== LOADING & ERROR TESTS ====================

    testWidgets('should show a spinner while loading', (tester) async {
      // Arrange & Act
      await pump(tester, const SynchronizationsLoading());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Backup'), findsOneWidget);
    });

    testWidgets('should show a localized error with retry', (tester) async {
      // Arrange
      await pump(tester, const SynchronizationError(NetworkFailure()));

      // Act
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      // ErrorDisplay shows its own spinner briefly before retrying.
      await tester.pump(const Duration(seconds: 2));

      // Assert
      expect(find.byType(ErrorDisplay), findsOneWidget);
      verify(() => syncBloc.add(const LoadSynchronizations())).called(1);
    });

    testWidgets('should show the loader while loading more sessions of the full list', (tester) async {
      // Arrange
      await pump(tester, SynchronizationsLoaded(
        sessions: [session('1', SynchronizationStatus.completed)],
        hasMore: true,
        currentPage: 0,
        isLoadingMore: true,
      ));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Act
      await tester.tap(find.text('See all'));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ==================== BACKUP PROCESS TESTS ====================

    testWidgets('should start the backup in place without leaving the tab', (tester) async {
      // Arrange
      await pump(tester, loaded(1));

      // Act
      await tester.tap(find.text('Back up now'));
      await tester.pump(const Duration(milliseconds: 60));

      // Assert
      verify(() => sessionBloc.add(const SyncSessionReset())).called(1);
      verify(() => sessionBloc.add(any(that: isA<SyncSessionStarted>()))).called(1);
      expect(find.byType(SynchronizationPage), findsOneWidget);
    });

    testWidgets('should follow the running backup in the status card', (tester) async {
      // Arrange
      await pump(tester, loaded(1));

      // Act
      await emitSession(tester, const SyncSessionUploading(uploadCount: 3, totalCount: 12));

      // Assert
      expect(find.text('Backing up 3 of 12'), findsOneWidget);
      expect(find.text('Back up now'), findsNothing);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should estimate the time left once enough files are uploaded', (tester) async {
      // Arrange
      await pump(tester, loaded(1));
      await emitSession(tester, const SyncSessionUploading(uploadCount: 0, totalCount: 13));

      // Act: 3 files in 3 minutes → 1 min per file, 10 left
      now = now.add(const Duration(minutes: 3));
      await emitSession(tester, const SyncSessionUploading(uploadCount: 3, totalCount: 13));

      // Assert
      expect(find.text('About 10 min left'), findsOneWidget);
    });

    testWidgets('should say the backup keeps running in the background', (tester) async {
      // Arrange
      await pump(tester, loaded(1));

      // Act
      await emitSession(tester, const SyncSessionFetchingFiles());

      // Assert
      expect(find.textContaining('You can leave the app'), findsOneWidget);
    });

    testWidgets('should not promise background work when the OS may stop it', (tester) async {
      // Arrange
      await pump(tester, loaded(1), background: false);

      // Act
      await emitSession(tester, const SyncSessionFetchingFiles());

      // Assert
      expect(find.textContaining('You can leave the app'), findsNothing);
    });

    testWidgets('should cancel the backup after confirming', (tester) async {
      // Arrange
      await pump(tester, loaded(1));
      await emitSession(tester, const SyncSessionUploading(uploadCount: 3, totalCount: 12));

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes, cancel'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => sessionBloc.add(const SyncSessionCancelled())).called(1);
      expect(find.text('Cancelling…'), findsOneWidget);
    });

    testWidgets('should report a cancelled backup and refresh the activity', (tester) async {
      // Arrange
      await pump(tester, loaded(1));
      await emitSession(tester, const SyncSessionUploading(uploadCount: 3, totalCount: 12));

      // Act
      await emitSession(tester, const SyncSessionCancelling(3));

      // Assert
      expect(find.text('Backup cancelled'), findsOneWidget);
      expect(find.text('Back up now'), findsOneWidget);
      verify(() => syncBloc.add(const RefreshSynchronizations())).called(1);
    });

    testWidgets('should report the saved items when the backup finishes', (tester) async {
      // Arrange
      await pump(tester, loaded(1));
      await emitSession(tester, const SyncSessionCompleting());

      // Act
      await emitSession(tester, SyncSessionSuccess(SyncResult(totalFiles: 12, uploadedFiles: 12, failedFiles: 0)));

      // Assert
      expect(find.text('12 items saved'), findsWidgets);
      expect(find.text('Back up now'), findsOneWidget);
    });

    testWidgets('should show the error of a failed backup with retry', (tester) async {
      // Arrange
      await pump(tester, loaded(1));
      await emitSession(tester, const SyncSessionFetchingFiles());

      // Act
      await emitSession(tester, const SyncSessionError(NetworkFailure()));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      verify(() => syncBloc.add(const RefreshSynchronizations())).called(1);
    });

    // ==================== ACTIVITY TESTS ====================

    testWidgets('should show the latest five backups until "See all" is tapped', (tester) async {
      // Arrange
      await pump(tester, loaded(8));
      expect(find.byType(SynchronizationListItem), findsNWidgets(5));

      // Act
      await tester.tap(find.text('See all'));
      await tester.pump();

      // Assert
      expect(find.byType(SynchronizationListItem), findsNWidgets(8));
      expect(find.text('See less'), findsOneWidget);
    });

    testWidgets('should not offer "See all" with few backups', (tester) async {
      // Arrange & Act
      await pump(tester, loaded(3));

      // Assert
      expect(find.text('See all'), findsNothing);
    });

    testWidgets('should start a new backup from a failed row', (tester) async {
      // Arrange
      await pump(tester, SynchronizationsLoaded(
        sessions: [session('1', SynchronizationStatus.failed)],
        hasMore: false,
        currentPage: 0,
      ));

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(milliseconds: 60));

      // Assert
      verify(() => sessionBloc.add(any(that: isA<SyncSessionStarted>()))).called(1);
    });

    testWidgets('should hide retry on failed rows while a backup runs', (tester) async {
      // Arrange
      await pump(tester, SynchronizationsLoaded(
        sessions: [session('1', SynchronizationStatus.failed)],
        hasMore: false,
        currentPage: 0,
      ));

      // Act
      await emitSession(tester, const SyncSessionFetchingFiles());

      // Assert
      expect(find.text('Retry'), findsNothing);
    });
  });
}
