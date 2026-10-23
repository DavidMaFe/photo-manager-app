import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/presentation/widgets/local_albums_settings_tile.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(WidgetTester tester, Future<List<LocalAlbum>> Function() load) async {
    await tester.pumpWidget(makeTestableWidget(Scaffold(body: LocalAlbumsSettingsTile(loadAlbums: load))));
    await tester.pumpAndSettle();
  }

  group('LocalAlbumsSettingsTile', () {
    testWidgets('should say how many albums the gallery has and how many are not backed up', (tester) async {
      await pump(tester, () async => [
            TestLocalAlbums.cameraOnServer.withAssetCount(1500),
            TestLocalAlbums.whatsappOnServer.withAssetCount(100),
            TestLocalAlbums.vacacionesOnServer, // no longer in the gallery
          ]);

      expect(find.text('Albums on the phone'), findsOneWidget);
      expect(find.text('2 albums · 1 not backed up'), findsOneWidget);
    });

    testWidgets('should only count the albums when all are backed up', (tester) async {
      await pump(tester, () async => [TestLocalAlbums.cameraOnServer.withAssetCount(1500)]);

      expect(find.text('1 album'), findsOneWidget);
    });

    testWidgets('should show the row without a summary when the albums cannot be read', (tester) async {
      await pump(tester, () async => throw Exception('Network error'));

      expect(find.text('Albums on the phone'), findsOneWidget);
      expect(find.textContaining('album'), findsNothing);
    });
  });
}
