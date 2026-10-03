import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_album_card.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/folder_card.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  Widget build(Folder folder, {VoidCallback? onTap, VoidCallback? onRename, VoidCallback? onDelete}) {
    return makeTestableWidget(Scaffold(
      body: Center(
        child: SizedBox(
          width: 170,
          child: FolderCard(folder: folder, onTap: onTap, onRename: onRename, onDelete: onDelete),
        ),
      ),
    ));
  }

  group('FolderCard', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the name and item/sub-album counts', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(build(TestFolders.album()));

      // Assert
      expect(find.text('Vacation'), findsOneWidget);
      expect(find.text('42 · 3 sub-albums'), findsOneWidget);
    });

    testWidgets('should show only the item count without sub-albums', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(build(TestFolders.album(fileCount: 1, subfolderCount: 0)));

      // Assert
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('should show "Empty" for empty albums', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(build(TestFolders.album(fileCount: 0, subfolderCount: 0)));

      // Assert
      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('should render a square cover', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(build(TestFolders.album()));

      // Assert
      final cover = tester.getSize(find.byType(AspectRatio));
      expect(cover.width, 170);
      expect(cover.height, 170);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      var taps = 0;
      await tester.pumpWidget(build(TestFolders.album(), onTap: () => taps++));

      // Act
      await tester.tap(find.text('Vacation'));

      // Assert
      expect(taps, 1);
    });

    // ==================== CONTEXT MENU TESTS ====================

    testWidgets('should open rename and delete on long press', (tester) async {
      // Arrange
      var renames = 0;
      await tester.pumpWidget(build(TestFolders.album(), onRename: () => renames++, onDelete: () {}));

      // Act
      await tester.longPress(find.byType(FolderCard));
      await tester.pumpAndSettle();
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      // Assert
      expect(renames, 1);
    });

    testWidgets('should call onDelete from the menu', (tester) async {
      // Arrange
      var deletes = 0;
      await tester.pumpWidget(build(TestFolders.album(), onRename: () {}, onDelete: () => deletes++));

      // Act
      await tester.longPress(find.byType(FolderCard));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(deletes, 1);
    });

    testWidgets('should not show a menu without actions', (tester) async {
      // Arrange
      await tester.pumpWidget(build(TestFolders.album()));

      // Act
      await tester.longPress(find.byType(FolderCard));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Rename'), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    // ==================== EDGE CASE TESTS ====================

    testWidgets('should ellipsize long names', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(build(TestFolders.album(name: 'A' * 120)));

      // Assert
      final text = tester.widget<Text>(find.text('A' * 120));
      expect(text.maxLines, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle unicode names', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(build(TestFolders.album(name: '日本 🎌 Été')));

      // Assert
      expect(find.text('日本 🎌 Été'), findsOneWidget);
    });
  });

  group('CreateAlbumCard', () {
    testWidgets('should show the label and call onTap', (tester) async {
      // Arrange
      var taps = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: Center(child: SizedBox.square(dimension: 160, child: CreateAlbumCard(label: 'Create album', onTap: () => taps++))),
      )));

      // Act
      await tester.tap(find.text('Create album'));

      // Assert
      expect(taps, 1);
    });
  });
}
