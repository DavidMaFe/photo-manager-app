import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/rename_folder_modal.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockFolderBloc extends Mock implements FolderBloc {}

void main() {
  late MockFolderBloc mockFolderBloc;

  setUp(() {
    mockFolderBloc = MockFolderBloc();
    when(() => mockFolderBloc.stream)
        .thenAnswer((_) => Stream.value(const FolderStarting()));
    when(() => mockFolderBloc.state).thenReturn(const FolderStarting());
  });

  group('RenameFolderModal', () {
    final testFolder = Folder(
      id: 'folder-1',
      name: 'Vacation',
      parentFolderId: null,
      path: '/root/folder-1',
      createdAt: DateTime(2024, 1, 15),
      fileCount: 0,
      subfolderCount: 0,
    );

    Widget createWidgetUnderTest({
      required Folder folder,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<FolderBloc>.value(
            value: mockFolderBloc,
            child: RenameFolderModal(
              folder: folder,
            ),
          ),
        ),
      );
    }

    testWidgets('should render modal container', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        folder: testFolder,
      ));

      // Assert
      expect(find.byType(RenameFolderModal), findsOneWidget);
    });

    testWidgets('should display text field with current name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        folder: testFolder,
      ));

      // Assert
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle special characters in current name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        folder: Folder(
          id: testFolder.id,
          name: 'Folder @#\$%',
          parentFolderId: testFolder.parentFolderId,
          path: testFolder.path,
          createdAt: testFolder.createdAt,
          fileCount: testFolder.fileCount,
          subfolderCount: testFolder.subfolderCount,
        ),
      ));

      // Assert
      expect(find.byType(RenameFolderModal), findsOneWidget);
    });

    testWidgets('should handle unicode characters in current name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        folder: Folder(
          id: testFolder.id,
          name: 'Vacaciones 🏖️',
          parentFolderId: testFolder.parentFolderId,
          path: testFolder.path,
          createdAt: testFolder.createdAt,
          fileCount: testFolder.fileCount,
          subfolderCount: testFolder.subfolderCount,
        ),
      ));

      // Assert
      expect(find.byType(RenameFolderModal), findsOneWidget);
    });

    testWidgets('should render with long folder name', (tester) async {
      // Arrange
      final longName = 'a' * 100;

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        folder: Folder(
          id: testFolder.id,
          name: longName,
          parentFolderId: testFolder.parentFolderId,
          path: testFolder.path,
          createdAt: testFolder.createdAt,
          fileCount: testFolder.fileCount,
          subfolderCount: testFolder.subfolderCount,
        ),
      ));

      // Assert
      expect(find.byType(RenameFolderModal), findsOneWidget);
    });

    testWidgets('should handle empty current name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        folder: Folder(
          id: testFolder.id,
          name: '',
          parentFolderId: testFolder.parentFolderId,
          path: testFolder.path,
          createdAt: testFolder.createdAt,
          fileCount: testFolder.fileCount,
          subfolderCount: testFolder.subfolderCount,
        ),
      ));

      // Assert
      expect(find.byType(RenameFolderModal), findsOneWidget);
    });
  });
}
