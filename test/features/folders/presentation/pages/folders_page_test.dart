import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/pages/folders_page.dart';
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

  group('FoldersPage', () {
    final testDate = DateTime(2024, 1, 15);

    Widget createWidgetUnderTest() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<FolderBloc>.value(
          value: mockFolderBloc,
          child: const FoldersPage(),
        ),
      );
    }

    testWidgets('should display app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render page without error', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FoldersPage), findsOneWidget);
    });

    testWidgets('should display folder list when loaded', (tester) async {
      // Arrange
      final folders = [
        Folder(
          id: 'folder-1',
          name: 'Vacation',
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 42,
          subfolderCount: 3,
        ),
        Folder(
          id: 'folder-2',
          name: 'Work',
          parentFolderId: null,
          path: '/root/folder-2',
          createdAt: testDate,
          fileCount: 15,
          subfolderCount: 0,
        ),
      ];

      when(() => mockFolderBloc.state)
          .thenReturn(FolderLoaded(folders: folders, currentParentId: null));
      when(() => mockFolderBloc.stream)
          .thenAnswer((_) => Stream.value(
              FolderLoaded(folders: folders, currentParentId: null)));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FoldersPage), findsOneWidget);
    });

    testWidgets('should use BlocBuilder to listen to FolderBloc', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(BlocBuilder<FolderBloc, FolderState>), findsWidgets);
    });

    testWidgets('should display scaffold', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle empty state', (tester) async {
      // Arrange
      when(() => mockFolderBloc.state)
          .thenReturn(const FolderLoaded(folders: [], currentParentId: null));
      when(() => mockFolderBloc.stream).thenAnswer((_) =>
          Stream.value(const FolderLoaded(folders: [], currentParentId: null)));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FoldersPage), findsOneWidget);
    });

    testWidgets('should render with multiple folders', (tester) async {
      // Arrange
      final manyFolders = List.generate(
        10,
        (i) => Folder(
          id: 'folder-$i',
          name: 'Folder $i',
          parentFolderId: null,
          path: '/root/folder-$i',
          createdAt: testDate,
          fileCount: i * 10,
          subfolderCount: i,
        ),
      );

      when(() => mockFolderBloc.state)
          .thenReturn(FolderLoaded(folders: manyFolders, currentParentId: null));
      when(() => mockFolderBloc.stream).thenAnswer((_) =>
          Stream.value(FolderLoaded(folders: manyFolders, currentParentId: null)));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FoldersPage), findsOneWidget);
    });
  });
}
