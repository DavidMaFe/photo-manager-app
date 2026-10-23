import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/presentation/bloc/local_albums_cubit.dart';
import 'package:photo_manager_app/features/local_albums/presentation/pages/local_albums_page.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockLocalAlbumsCubit extends MockCubit<LocalAlbumsState> implements LocalAlbumsCubit {}

void main() {
  late MockLocalAlbumsCubit cubit;
  final vacaciones = TestLocalAlbums.vacacionesOnServer.withAssetCount(600);
  final camera = TestLocalAlbums.cameraOnServer.withAssetCount(1500);

  setUp(() {
    cubit = MockLocalAlbumsCubit();
    when(() => cubit.finish()).thenAnswer((_) async {});
    when(() => cubit.change(any(), any())).thenAnswer((_) async {});
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.requestPermission()).thenAnswer((_) async {});
  });

  setUpAll(() => registerFallbackValue(LocalAlbumMode.album));

  Future<void> pump(WidgetTester tester, LocalAlbumsState state,
      {bool review = false, Stream<LocalAlbumsState>? states}) async {
    setUpCustomScreenSize(tester, 390, 1200);
    whenListen(cubit, states ?? const Stream<LocalAlbumsState>.empty(), initialState: state);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('home')), routes: [
        GoRoute(
          path: 'albums',
          builder: (_, __) => BlocProvider<LocalAlbumsCubit>.value(value: cubit, child: LocalAlbumsPage(review: review)),
        ),
      ]),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router));
    router.push('/albums');
    await tester.pumpAndSettle();
  }

  group('LocalAlbumsPage', () {
    group('Tus álbumes', () {
      testWidgets('should show the albums with their options and «Continuar»', (tester) async {
        await pump(tester, LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [camera, vacaciones]),
            review: true);

        expect(find.text('Your albums'), findsOneWidget);
        expect(find.textContaining('We found 2 albums on your phone.'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('1500 files'), findsOneWidget);
        expect(find.text('Vacaciones 2025'), findsOneWidget);
        expect(find.text('As an album'), findsOneWidget);
        expect(find.text('Backup only'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('should keep a change for «Continuar»', (tester) async {
        await pump(tester, LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [camera]), review: true);

        await tester.tap(find.byKey(ValueKey('local-album-mode-${camera.localAlbumId}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Do not back up').last);
        await tester.pumpAndSettle();

        verify(() => cubit.choose(camera.localAlbumId, LocalAlbumMode.excluded)).called(1);
        verifyNever(() => cubit.change(any(), any()));
      });

      testWidgets('should save with «Continuar» and close when it is done', (tester) async {
        final loaded = LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [camera]);
        await pump(tester, loaded, review: true,
            states: Stream.fromIterable([loaded.copyWith(status: LocalAlbumsStatus.done)]));

        expect(find.text('home'), findsOneWidget);
      });

      testWidgets('should call finish when «Continuar» is tapped', (tester) async {
        await pump(tester, LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [camera]), review: true);

        await tester.tap(find.byKey(const ValueKey('local-albums-continue')));
        await tester.pump();

        verify(() => cubit.finish()).called(1);
      });
    });

    group('settings', () {
      testWidgets('should save each change at once, without «Continuar»', (tester) async {
        await pump(tester, LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [vacaciones]));

        expect(find.text('Albums on the phone'), findsOneWidget);
        expect(find.byKey(const ValueKey('local-albums-continue')), findsNothing);

        await tester.tap(find.byKey(ValueKey('local-album-mode-${vacaciones.localAlbumId}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Backup only').last);
        await tester.pumpAndSettle();

        verify(() => cubit.change(vacaciones.localAlbumId, LocalAlbumMode.backupOnly)).called(1);
      });

      testWidgets('should say when there are no albums in the gallery', (tester) async {
        await pump(tester, const LocalAlbumsState(status: LocalAlbumsStatus.loaded));

        expect(find.text('There are no albums in your gallery'), findsOneWidget);
      });

      testWidgets('should ask for the photo access when it is missing', (tester) async {
        await pump(tester, const LocalAlbumsState(status: LocalAlbumsStatus.noPermission));

        expect(find.text('Photo access is missing'), findsOneWidget);
        await tester.tap(find.text('Allow access'));
        await tester.pump();

        verify(() => cubit.requestPermission()).called(1);
      });

      testWidgets('should say when only some photos can be read', (tester) async {
        await pump(tester, LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [camera], limitedAccess: true));

        expect(find.byKey(const ValueKey('local-albums-limited')), findsOneWidget);
      });

      testWidgets('should offer to retry when the albums cannot be loaded', (tester) async {
        await pump(tester, const LocalAlbumsState(status: LocalAlbumsStatus.error, failure: UnknownFailure()));

        expect(find.text('The albums could not be loaded'), findsOneWidget);
        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(() => cubit.load()).called(1);
      });
    });
  });
}
