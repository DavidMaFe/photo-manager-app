import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/folder_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  group('FolderCard', () {
    final testDate = DateTime(2024, 1, 15);

    Widget createWidgetUnderTest({
      required Folder folder,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FolderCard(
            folder: folder,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('should display folder name', (tester) async {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folder: folder));

      // Assert
      expect(find.text('Vacation'), findsOneWidget);
    });

    testWidgets('should render without error', (tester) async {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Test',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folder: folder));

      // Assert
      expect(find.byType(FolderCard), findsOneWidget);
    });

    testWidgets('should be tappable', (tester) async {
      // Arrange
      var tapped = false;
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        folder: folder,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(FolderCard));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should handle folder with special characters', (tester) async {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Folder @#\$%',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folder: folder));

      // Assert
      expect(find.text('Folder @#\$%'), findsOneWidget);
    });

    testWidgets('should handle folder with unicode characters', (tester) async {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacaciones 🏖️ 日本',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folder: folder));

      // Assert
      expect(find.text('Vacaciones 🏖️ 日本'), findsOneWidget);
    });

    testWidgets('should handle long folder name', (tester) async {
      // Arrange
      final longName = 'a' * 100;
      final folder = Folder(
        id: 'folder-1',
        name: longName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folder: folder));

      // Assert
      expect(find.text(longName), findsOneWidget);
    });

    testWidgets('should work without onTap callback', (tester) async {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(folder: folder));

      // Assert
      expect(find.byType(FolderCard), findsOneWidget);
    });
  });
}
