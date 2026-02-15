import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_bloc.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/pages/synchronization_page.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/empty_synchronization_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/error_synchronization_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_list_item.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_status_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockSynchronizationBloc
    extends MockBloc<SynchronizationEvent, SynchronizationState>
    implements SynchronizationBloc {}

void main() {
  late MockSynchronizationBloc mockBloc;

  setUp(() {
    mockBloc = MockSynchronizationBloc();
  });

  final testDate = DateTime(2024, 1, 15);

  final testSynchronizations = [
    Synchronization(
      id: 'sync-1',
      startedAt: testDate,
      status: SynchronizationStatus.completed,
      totalFiles: 100,
      uploadedFiles: 100,
      failedFiles: 0,
    ),
    Synchronization(
      id: 'sync-2',
      startedAt: testDate.subtract(const Duration(days: 1)),
      status: SynchronizationStatus.failed,
      totalFiles: 50,
      uploadedFiles: 30,
      failedFiles: 20,
    ),
  ];

  Widget buildTestWidget(SynchronizationState state) {
    when(() => mockBloc.state).thenReturn(state);
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(state));

    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: BlocProvider<SynchronizationBloc>.value(
        value: mockBloc,
        child: const SynchronizationPage(),
      ),
    );
  }

  group('SynchronizationPage', () {
    testWidgets('should display AppBar with title', (tester) async {
      when(() => mockBloc.state).thenReturn(const SynchronizationsLoading());
      when(() => mockBloc.stream)
          .thenAnswer((_) => Stream.value(const SynchronizationsLoading()));

      await tester.pumpWidget(buildTestWidget(const SynchronizationsLoading()));

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display loading indicator when state is SynchronizationsLoading',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(const SynchronizationsLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state when state is SynchronizationError',
        (tester) async {
      const errorState = SynchronizationError(NetworkFailure());

      await tester.pumpWidget(buildTestWidget(errorState));

      expect(find.byType(ErrorSynchronizationState), findsOneWidget);
    });

    testWidgets('should trigger LoadSynchronizations on error retry', (tester) async {
      const errorState = SynchronizationError(NetworkFailure());

      await tester.pumpWidget(buildTestWidget(errorState));
      await tester.pump();

      final retryButton = find.text('Try again');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      verify(() => mockBloc.add(const LoadSynchronizations())).called(1);
    });

    testWidgets('should display empty state when loaded with no sessions',
        (tester) async {
      const emptyState = SynchronizationsLoaded(
        sessions: [],
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(emptyState));

      expect(find.byType(EmptySynchronizationState), findsOneWidget);
    });

    testWidgets('should display SynchronizationStatusCard when loaded with sessions',
        (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      expect(find.byType(SynchronizationStatusCard), findsOneWidget);
    });

    testWidgets('should display list of synchronization items', (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      expect(find.byType(SynchronizationListItem), findsNWidgets(2));
    });

    testWidgets('should display RefreshIndicator when loaded', (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should trigger RefreshSynchronizations on pull to refresh',
        (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      verify(() => mockBloc.add(const RefreshSynchronizations())).called(1);
    });

    testWidgets('should display loading indicator when hasMore is true and isLoadingMore',
        (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: true,
        currentPage: 0,
        isLoadingMore: true,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      // Loading indicator is at the bottom, need to scroll or find it with skipOffstage
      expect(find.byType(CircularProgressIndicator, skipOffstage: false), findsAtLeastNWidgets(1));
    });

    testWidgets('should not display loading indicator when hasMore is false',
        (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: false,
        currentPage: 0,
        isLoadingMore: false,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      // Should find no CircularProgressIndicator (since none are visible)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should trigger LoadMoreSynchronizations on scroll to bottom',
        (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: true,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      // Scroll to bottom
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -1000),
      );
      await tester.pump();

      verify(() => mockBloc.add(const LoadMoreSynchronizations())).called(greaterThan(0));
    });

    testWidgets('should display CustomScrollView when loaded with sessions',
        (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should display default loading when state is SynchronizationStarting',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(const SynchronizationStarting()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle single synchronization session', (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: [testSynchronizations.first],
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      expect(find.byType(SynchronizationListItem), findsOneWidget);
    });

    testWidgets('should display historic section title when loaded with sessions',
        (tester) async {
      final loadedState = SynchronizationsLoaded(
        sessions: testSynchronizations,
        hasMore: false,
        currentPage: 0,
      );

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pump();

      expect(find.byType(SliverToBoxAdapter), findsWidgets);
    });
  });
}
