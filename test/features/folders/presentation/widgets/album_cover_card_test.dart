import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_cover_card.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_mosaic.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('AlbumCoverCard', () {
    testWidgets('should show how many covers were chosen and their mosaic', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: AlbumCoverCard(folder: TestFolders.album(coverFileIds: ['a', 'b']), onEdit: () {}),
      )));

      // Assert
      expect(find.text('Cover'), findsOneWidget);
      expect(find.text('2 of 3 photos'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      final mosaic = tester.widget<AlbumMosaic>(find.byType(AlbumMosaic));
      expect(mosaic.fileIds, ['a', 'b']);
      expect(mosaic.radius, 12);
      expect(tester.getSize(find.byType(AlbumMosaic)), const Size(52, 52));
    });

    testWidgets('should say the covers are automatic without chosen ones', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: AlbumCoverCard(folder: TestFolders.album(fallbackCoverFileIds: ['r']), onEdit: () {}),
      )));

      // Assert
      expect(find.text('Automatic · recent photos'), findsOneWidget);
      expect(tester.widget<AlbumMosaic>(find.byType(AlbumMosaic)).fileIds, ['r']);
    });

    testWidgets('should edit on tap', (tester) async {
      // Arrange
      var edits = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: AlbumCoverCard(folder: TestFolders.album(), onEdit: () => edits++),
      )));

      // Act
      await tester.tap(find.byType(AlbumCoverCard));

      // Assert
      expect(edits, 1);
    });
  });
}
