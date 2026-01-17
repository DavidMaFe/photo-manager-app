import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_uploading_files.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockSyncSessionBloc extends Mock implements SyncSessionBloc {}

void main() {
  late MockSyncSessionBloc mockBloc;

  setUp(() {
    mockBloc = MockSyncSessionBloc();
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(const SyncSessionInitial()));
    when(() => mockBloc.state).thenReturn(const SyncSessionInitial());
  });

  Widget createWidgetUnderTest({int uploadCount = 5, int totalCount = 10}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: BlocProvider<SyncSessionBloc>.value(
        value: mockBloc,
        child: Scaffold(
          body: SyncSessionUploadingFiles(
            uploadCount: uploadCount,
            totalCount: totalCount,
          ),
        ),
      ),
    );
  }

  group('SyncSessionUploadingFiles', () {
    testWidgets('should display upload icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    });

    testWidgets('should display uploading files message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Subiendo archivos...'), findsOneWidget);
    });

    testWidgets('should display progress bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display correct progress count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(uploadCount: 7, totalCount: 15));

      // Assert
      expect(find.text('7/15 archivos'), findsOneWidget);
    });

    testWidgets('should display correct percentage', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(uploadCount: 5, totalCount: 10));

      // Assert
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should display cancel button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Cancelar sincronización'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should show cancel dialog when cancel button tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Cancelar sincronización'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('should calculate progress correctly when totalCount is zero', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(uploadCount: 0, totalCount: 0));

      // Assert
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
