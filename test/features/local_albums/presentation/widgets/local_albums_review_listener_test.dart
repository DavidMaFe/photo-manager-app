import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/presentation/widgets/local_albums_review_listener.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  late List<Object?> opened;

  Future<void> pump(WidgetTester tester, Future<List<LocalAlbum>?> Function() check) async {
    opened = [];
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => LocalAlbumsReviewListener(check: check, child: const Scaffold(body: Text('home'))),
      ),
      GoRoute(
        path: RoutePaths.localAlbumsReview,
        name: RouteNames.localAlbumsReview,
        builder: (_, state) {
          opened.add(state.extra);
          return const Scaffold(body: Text('review'));
        },
      ),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router));
    await tester.pumpAndSettle();
  }

  setUp(() => LocalAlbumsReviewListener.checkedThisSession = false);

  group('LocalAlbumsReviewListener', () {
    testWidgets('should open «Tus álbumes» with the albums to review', (tester) async {
      await pump(tester, () async => [TestLocalAlbums.vacacionesOnServer]);

      expect(find.text('review'), findsOneWidget);
      expect(opened.single, [TestLocalAlbums.vacacionesOnServer]);
    });

    testWidgets('should stay on the main screens when there is nothing to review', (tester) async {
      await pump(tester, () async => null);

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('should stay on the main screens when the check fails', (tester) async {
      await pump(tester, () async => throw Exception('Network error'));

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('should check only once per app session', (tester) async {
      var checks = 0;
      await pump(tester, () async {
        checks++;
        return null;
      });
      await pump(tester, () async {
        checks++;
        return null;
      });

      expect(checks, 1);
    });
  });
}
