import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';
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

void main() {
  late MockSynchronizationBloc syncBloc;
  late MockSyncConfigBloc configBloc;

  setUp(() {
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

  Future<void> pump(WidgetTester tester, SynchronizationState state) {
    setUpCustomScreenSize(tester, 390, 1400);
    when(() => syncBloc.state).thenReturn(state);
    return tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<SynchronizationBloc>.value(value: syncBloc),
        BlocProvider<SyncConfigBloc>.value(value: configBloc),
      ],
      child: const SynchronizationPage(),
    ));
  }

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

    testWidgets('should show the loader while loading more sessions', (tester) async {
      // Arrange & Act
      await pump(tester, SynchronizationsLoaded(
        sessions: [session('1', SynchronizationStatus.completed)],
        hasMore: true,
        currentPage: 0,
        isLoadingMore: true,
      ));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
