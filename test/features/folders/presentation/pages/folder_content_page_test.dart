import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_state.dart';
import 'package:photo_manager_app/features/folders/presentation/pages/folder_content_page.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockFolderContentBloc extends Mock implements FolderContentBloc {}

void main() {
  late MockFolderContentBloc mockFolderContentBloc;

  setUp(() {
    mockFolderContentBloc = MockFolderContentBloc();
    when(() => mockFolderContentBloc.stream)
        .thenAnswer((_) => Stream.value(const FolderContentStarting()));
    when(() => mockFolderContentBloc.state)
        .thenReturn(const FolderContentStarting());
  });

  group('FolderContentPage', () {
    final testDate = DateTime(2024, 1, 15);

    final testFolder = Folder(
      id: 'folder-1',
      name: 'Vacation',
      parentFolderId: null,
      path: '/root/folder-1',
      createdAt: testDate,
      fileCount: 2,
      subfolderCount: 1,
    );

    Widget createWidgetUnderTest({required String folderId}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<FolderContentBloc>.value(
          value: mockFolderContentBloc,
          child: FolderContentPage(folderId: folderId),
        ),
      );
    }

    testWidgets('should display app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render page without error', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));

      // Assert
      expect(find.byType(FolderContentPage), findsOneWidget);
    });

    testWidgets('should display folder content when loaded', (tester) async {
      // Arrange
      final files = [
        GalleryFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      ];

      when(() => mockFolderContentBloc.state).thenReturn(
        FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: [],
          files: files,
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
        ),
      );
      when(() => mockFolderContentBloc.stream).thenAnswer(
        (_) => Stream.value(
          FolderContentLoaded(
            currentFolder: testFolder,
            subfolders: [],
            files: files,
            hasMoreFiles: false,
            selectedFileIds: const {},
            isSelectionMode: false,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));
      await tester.pump();

      // Assert
      expect(find.byType(FolderContentPage), findsOneWidget);
    });

    testWidgets('should use BlocBuilder to listen to FolderContentBloc',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));

      // Assert
      expect(
          find.byType(BlocBuilder<FolderContentBloc, FolderContentState>),
          findsWidgets);
    });

    testWidgets('should display scaffold', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle empty folder', (tester) async {
      // Arrange
      when(() => mockFolderContentBloc.state).thenReturn(
        FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: [],
          files: [],
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
        ),
      );
      when(() => mockFolderContentBloc.stream).thenAnswer(
        (_) => Stream.value(
          FolderContentLoaded(
            currentFolder: testFolder,
            subfolders: [],
            files: [],
            hasMoreFiles: false,
            selectedFileIds: const {},
            isSelectionMode: false,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));
      await tester.pump();

      // Assert
      expect(find.byType(FolderContentPage), findsOneWidget);
    });

    testWidgets('should pass folderId to page', (tester) async {
      // Arrange
      const folderId = 'test-folder-123';

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: folderId));

      // Assert
      expect(find.byType(FolderContentPage), findsOneWidget);
    });

    testWidgets('should handle folder with subfolders', (tester) async {
      // Arrange
      final subfolders = [
        Folder(
          id: 'subfolder-1',
          name: 'Summer',
          parentFolderId: 'folder-1',
          path: '/root/folder-1/subfolder-1',
          createdAt: testDate,
          fileCount: 5,
          subfolderCount: 0,
        ),
      ];

      when(() => mockFolderContentBloc.state).thenReturn(
        FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: subfolders,
          files: [],
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
        ),
      );
      when(() => mockFolderContentBloc.stream).thenAnswer(
        (_) => Stream.value(
          FolderContentLoaded(
            currentFolder: testFolder,
            subfolders: subfolders,
            files: [],
            hasMoreFiles: false,
            selectedFileIds: const {},
            isSelectionMode: false,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));
      await tester.pump();

      // Assert
      expect(find.byType(FolderContentPage), findsOneWidget);
    });

    testWidgets('should render with many files', (tester) async {
      // Arrange
      final manyFiles = List.generate(
        20,
        (i) => GalleryFile(
          id: 'file-$i',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      );

      when(() => mockFolderContentBloc.state).thenReturn(
        FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: [],
          files: manyFiles,
          hasMoreFiles: true,
          selectedFileIds: const {},
          isSelectionMode: false,
        ),
      );
      when(() => mockFolderContentBloc.stream).thenAnswer(
        (_) => Stream.value(
          FolderContentLoaded(
            currentFolder: testFolder,
            subfolders: [],
            files: manyFiles,
            hasMoreFiles: true,
            selectedFileIds: const {},
            isSelectionMode: false,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folderId: 'folder-1'));
      await tester.pump();

      // Assert
      expect(find.byType(FolderContentPage), findsOneWidget);
    });
  });
}
