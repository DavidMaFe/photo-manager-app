import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:photo_manager_app/features/favorites/presentation/widgets/favorite_viewer_button.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState> implements FavoritesBloc {}

void main() {
  const p = AppPalette.light;
  late MockFavoritesBloc bloc;

  setUp(() => bloc = MockFavoritesBloc());

  GalleryFile photo({bool favorite = false}) => GalleryFile(
        id: 'a',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: DateTime(2024),
        isFavorite: favorite,
      );

  Future<void> pump(WidgetTester tester, GalleryFile file, {FavoritesState state = const FavoritesState()}) {
    when(() => bloc.state).thenReturn(state);
    return tester.pumpWidget(makeTestableWidget(BlocProvider<FavoritesBloc>.value(
      value: bloc,
      child: Scaffold(body: Center(child: FavoriteViewerButton(file: file))),
    )));
  }

  MediaViewerAction action(WidgetTester tester) => tester.widget<MediaViewerAction>(find.byType(MediaViewerAction));

  group('FavoriteViewerButton', () {
    testWidgets('should show an outlined white heart when not a favorite', (tester) async {
      // Arrange & Act
      await pump(tester, photo());

      // Assert
      expect(find.text('Favorite'), findsOneWidget);
      expect(action(tester).iconFill, 0);
      expect(action(tester).iconColor, isNull);
      expect(action(tester).labelWeight, FontWeight.w700);
      expect(tester.getSemantics(find.byType(FavoriteViewerButton)), containsSemantics(hasToggledState: true, isToggled: false, label: 'Favorite'));
    });

    testWidgets('should show a filled pink heart when it is a favorite', (tester) async {
      // Arrange & Act
      await pump(tester, photo(favorite: true));

      // Assert
      expect(action(tester).iconFill, 1);
      expect(action(tester).iconColor, p.favorite);
      expect(action(tester).color, p.favoriteInk);
      expect(action(tester).labelWeight, FontWeight.w800);
      expect(tester.getSemantics(find.byType(FavoriteViewerButton)), containsSemantics(hasToggledState: true, isToggled: true));
    });

    testWidgets('should follow the value set in the bloc over the file', (tester) async {
      await pump(tester, photo(), state: const FavoritesState(overrides: {'a': true}));
      expect(action(tester).iconFill, 1);
    });

    testWidgets('should mark the file and pop the heart', (tester) async {
      // Arrange
      await pump(tester, photo());

      // Act
      await tester.tap(find.byIcon(Symbols.favorite_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));

      // Assert
      verify(() => bloc.add(SetFavorites(files: [photo()], favorite: true))).called(1);
      expect(action(tester).iconScale, greaterThan(1));
      await tester.pumpAndSettle();
      expect(action(tester).iconScale, 1);
    });

    testWidgets('should unmark a favorite without popping', (tester) async {
      // Arrange
      await pump(tester, photo(favorite: true));

      // Act
      await tester.tap(find.byIcon(Symbols.favorite_rounded));
      await tester.pump(const Duration(milliseconds: 110));

      // Assert
      verify(() => bloc.add(SetFavorites(files: [photo(favorite: true)], favorite: false))).called(1);
      expect(action(tester).iconScale, 1);
    });

    testWidgets('should show a snackbar when the change fails', (tester) async {
      // Arrange
      final states = StreamController<FavoritesState>();
      addTearDown(states.close);
      whenListen(bloc, states.stream, initialState: const FavoritesState());
      await tester.pumpWidget(makeTestableWidget(BlocProvider<FavoritesBloc>.value(
        value: bloc,
        child: Scaffold(body: Center(child: FavoriteViewerButton(file: photo()))),
      )));

      // Act
      states.add(const FavoritesState(outcome: FavoritesFailed(NetworkFailure())));
      await tester.pump();

      // Assert
      expect(find.text("Couldn't update. Please try again."), findsOneWidget);
    });
  });
}
