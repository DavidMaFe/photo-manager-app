import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/features/sync_session/presentation/pages/sync_session_process_page.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockSyncSessionBloc extends Mock implements SyncSessionBloc {}

void main() {
  late MockSyncSessionBloc mockBloc;

  setUp(() {
    mockBloc = MockSyncSessionBloc();
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(const SyncSessionInitial()));
  });

  Widget createWidgetUnderTest(SyncSessionState state) {
    when(() => mockBloc.state).thenReturn(state);

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: BlocProvider<SyncSessionBloc>.value(
        value: mockBloc,
        child: const SyncSessionProcessPage(),
      ),
    );
  }

  group('SyncSessionProcessPage', () {
    testWidgets('should display app bar with title', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(const SyncSessionInitial()));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Sincronización'), findsOneWidget);
    });

    testWidgets('should render SyncSessionInit widget when state is SyncSessionStarting', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(const SyncSessionStarting()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render SyncSessionFetchFiles widget when state is SyncSessionFetchingFiles', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(const SyncSessionFetchingFiles()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render SyncSessionUploadingFiles widget when state is SyncSessionUploading', (tester) async {
      // Arrange
      const state = SyncSessionUploading(uploadCount: 5, totalCount: 10);
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('5/10 archivos'), findsOneWidget);
    });

    testWidgets('should render SyncSessionComplete widget when state is SyncSessionCompleting', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(const SyncSessionCompleting()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render SyncSessionSuccessView widget when state is SyncSessionSuccess', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 10, uploadedFiles: 8, failedFiles: 2);
      final state = SyncSessionSuccess(result);
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('10 archivos'), findsOneWidget);
      expect(find.text('8 archivos'), findsOneWidget);
      expect(find.text('2 archivos'), findsOneWidget);
    });

    testWidgets('should render ErrorDisplay widget when state is SyncSessionError', (tester) async {
      // Arrange
      const failure = NetworkFailure(code: 'network_failure');
      const state = SyncSessionError(failure);
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert - Should show localized error message for NetworkFailure
      expect(find.text('Sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.'), findsOneWidget);
    });

    testWidgets('should show cancel dialog when back button pressed during upload', (tester) async {
      // Arrange
      const state = SyncSessionUploading(uploadCount: 5, totalCount: 10);
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Act - Simulate system back button press
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pump();
      await tester.pump();

      // Assert - ModernDialog is used instead of AlertDialog
      expect(find.byType(ModernDialog), findsOneWidget);
    });
  });
}
