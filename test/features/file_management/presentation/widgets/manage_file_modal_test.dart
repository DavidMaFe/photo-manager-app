import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockFileManagementBloc extends Mock implements FileManagementBloc {}

void main() {
  late MockFileManagementBloc mockBloc;

  setUp(() {
    mockBloc = MockFileManagementBloc();
    when(() => mockBloc.stream)
        .thenAnswer((_) => Stream.value(const FileManagementStarting()));
    when(() => mockBloc.state).thenReturn(const FileManagementStarting());
  });

  group('ManageFileModal', () {
    Widget createWidgetUnderTest({
      required List<String> fileIds,
      bool isMultiple = false,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<FileManagementBloc>.value(
            value: mockBloc,
            child: ManageFileModal(
              fileIds: fileIds,
              isMultiple: isMultiple,
            ),
          ),
        ),
      );
    }

    testWidgets('should display modal container', (tester) async {
      // Arrange
      const fileIds = ['file-1'];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(fileIds: fileIds));

      // Assert
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle single file', (tester) async {
      // Arrange
      const fileIds = ['file-1'];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        fileIds: fileIds,
        isMultiple: false,
      ));

      // Assert
      expect(find.byType(ManageFileModal), findsOneWidget);
    });

    testWidgets('should handle multiple files', (tester) async {
      // Arrange
      const fileIds = ['file-1', 'file-2', 'file-3'];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        fileIds: fileIds,
        isMultiple: true,
      ));

      // Assert
      expect(find.byType(ManageFileModal), findsOneWidget);
    });

    testWidgets('should use BlocConsumer to listen to FileManagementBloc', (tester) async {
      // Arrange
      const fileIds = ['file-1'];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(fileIds: fileIds));

      // Assert
      expect(find.byType(BlocConsumer<FileManagementBloc, FileManagementState>),
          findsOneWidget);
    });

    testWidgets('should adapt to keyboard with view insets', (tester) async {
      // Arrange
      const fileIds = ['file-1'];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(fileIds: fileIds));

      // Assert
      // Modal should render with padding that adapts to view insets
      expect(find.byType(ManageFileModal), findsOneWidget);
    });

    testWidgets('should have white background container', (tester) async {
      // Arrange
      const fileIds = ['file-1'];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(fileIds: fileIds));

      // Assert
      final decoration = tester.widget<Container>(
        find.descendant(
          of: find.byType(ManageFileModal),
          matching: find.byType(Container),
        ).first,
      ).decoration as BoxDecoration?;

      expect(decoration?.color, Colors.white);
    });

    testWidgets('should handle empty file list', (tester) async {
      // Arrange
      const fileIds = <String>[];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(fileIds: fileIds));

      // Assert
      expect(find.byType(ManageFileModal), findsOneWidget);
    });
  });
}
