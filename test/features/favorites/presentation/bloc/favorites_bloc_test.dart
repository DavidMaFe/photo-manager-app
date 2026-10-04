import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/favorites/domain/entities/favorite_result.dart';
import 'package:photo_manager_app/features/favorites/domain/use_cases/set_favorite_use_case.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

class MockSetFavoriteUseCase extends Mock implements SetFavoriteUseCase {}

void main() {
  late MockSetFavoriteUseCase useCase;
  late AppEventBus eventBus;
  late List<FavoritesChangedEvent> fired;

  setUp(() {
    useCase = MockSetFavoriteUseCase();
    eventBus = AppEventBus();
    fired = [];
    eventBus.on<FavoritesChangedEvent>().listen(fired.add);
  });

  GalleryFile file(String id, {bool favorite = false}) => GalleryFile(
        id: id,
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: DateTime(2024),
        isFavorite: favorite,
      );

  String describe(FavoritesChangedEvent e) => '${e.fileIds.join(',')}:${e.favorite}';

  FavoritesBloc build() => FavoritesBloc(setFavoriteUseCase: useCase, eventBus: eventBus);

  group('FavoritesBloc', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'should mark at once and report how many were saved',
      setUp: () => when(() => useCase(fileIds: ['a'], favorite: true))
          .thenAnswer((_) async => const FavoriteResult(updatedIds: ['a'], failedIds: [])),
      build: build,
      act: (bloc) => bloc.add(SetFavorites(files: [file('a')], favorite: true)),
      expect: () => [
        const FavoritesState(overrides: {'a': true}, isSaving: true),
        const FavoritesState(overrides: {'a': true}, outcome: FavoritesSaved(count: 1, favorite: true)),
      ],
      verify: (_) {
        expect(fired.single.fileIds, ['a']);
        expect(fired.single.favorite, isTrue);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should go back and report the failure when the request fails',
      setUp: () => when(() => useCase(fileIds: any(named: 'fileIds'), favorite: any(named: 'favorite')))
          .thenThrow(Exception('Network error')),
      build: build,
      act: (bloc) => bloc.add(SetFavorites(files: [file('a')], favorite: true)),
      expect: () => [
        const FavoritesState(overrides: {'a': true}, isSaving: true),
        const FavoritesState(overrides: {'a': false}, isSaving: true),
        isA<FavoritesState>()
            .having((s) => s.overrides, 'overrides', {'a': false})
            .having((s) => s.outcome, 'outcome', isA<FavoritesFailed>()),
      ],
      verify: (_) {
        expect(fired.map(describe), ['a:true', 'a:false']);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should restore only the files the server could not change, to their own previous value',
      setUp: () => when(() => useCase(fileIds: any(named: 'fileIds'), favorite: false))
          .thenAnswer((_) async => const FavoriteResult(updatedIds: ['a'], failedIds: ['b', 'c'])),
      build: build,
      act: (bloc) => bloc.add(SetFavorites(
        files: [file('a', favorite: true), file('b', favorite: true), file('c')],
        favorite: false,
      )),
      skip: 2,
      expect: () => [
        const FavoritesState(
          overrides: {'a': false, 'b': true, 'c': false},
          outcome: FavoritesSaved(count: 1, favorite: false),
        ),
      ],
      verify: (_) {
        expect(fired.map(describe), ['a,b,c:false', 'b:true', 'c:false']);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should report a failure when no file could change',
      setUp: () => when(() => useCase(fileIds: any(named: 'fileIds'), favorite: any(named: 'favorite')))
          .thenAnswer((_) async => const FavoriteResult(updatedIds: [], failedIds: ['a'])),
      build: build,
      act: (bloc) => bloc.add(SetFavorites(files: [file('a')], favorite: true)),
      skip: 2,
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.overrides, 'overrides', {'a': false})
            .having((s) => s.outcome, 'outcome', isA<FavoritesFailed>()),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should use the last value it set as the previous one',
      setUp: () => when(() => useCase(fileIds: any(named: 'fileIds'), favorite: any(named: 'favorite')))
          .thenThrow(Exception('Network error')),
      build: build,
      seed: () => const FavoritesState(overrides: {'a': true}),
      act: (bloc) => bloc.add(SetFavorites(files: [file('a')], favorite: false)),
      skip: 2,
      expect: () => [
        isA<FavoritesState>().having((s) => s.overrides, 'overrides', {'a': true}),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'should do nothing without files',
      build: build,
      act: (bloc) => bloc.add(const SetFavorites(files: [], favorite: true)),
      expect: () => const <FavoritesState>[],
    );

    test('isFavorite should prefer the value set here over the file', () {
      const state = FavoritesState(overrides: {'a': true});
      expect(state.isFavorite('a', fallback: false), isTrue);
      expect(state.isFavorite('b', fallback: true), isTrue);
      expect(state.isFavorite('b', fallback: false), isFalse);
    });
  });
}
