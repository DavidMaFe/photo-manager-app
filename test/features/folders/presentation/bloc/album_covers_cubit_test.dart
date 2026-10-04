import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/folders/domain/entities/album_cover.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_album_covers_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/set_album_covers_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/album_covers/album_covers_cubit.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/album_covers/album_covers_state.dart';

class MockGetAlbumCoversUseCase extends Mock implements GetAlbumCoversUseCase {}

class MockSetAlbumCoversUseCase extends Mock implements SetAlbumCoversUseCase {}

void main() {
  late MockGetAlbumCoversUseCase getCovers;
  late MockSetAlbumCoversUseCase setCovers;
  late AppEventBus eventBus;

  setUp(() {
    getCovers = MockGetAlbumCoversUseCase();
    setCovers = MockSetAlbumCoversUseCase();
    eventBus = AppEventBus();
  });

  AlbumCover cover(String id, int position) =>
      AlbumCover(fileId: id, position: position, sourceFolderId: 'a1', sourceFolderName: 'Playa');
  final a = cover('a', 0), b = cover('b', 1), c = cover('c', 2);

  AlbumCoversCubit build() => AlbumCoversCubit(
        getAlbumCoversUseCase: getCovers,
        setAlbumCoversUseCase: setCovers,
        eventBus: eventBus,
      );

  AlbumCoversState ready(List<AlbumCover> covers, {List<AlbumCover>? original}) => AlbumCoversState(
        status: AlbumCoversStatus.ready,
        folderId: 'a1',
        original: original ?? [a, b, c],
        covers: covers,
      );

  List<String> ids(AlbumCoversState s) => [for (final cover in s.covers) cover.fileId];

  group('AlbumCoversCubit', () {
    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should load the covers of the album',
      setUp: () => when(() => getCovers('a1')).thenAnswer((_) async => [a, b, c]),
      build: build,
      act: (cubit) => cubit.load('a1'),
      expect: () => [const AlbumCoversState(folderId: 'a1'), ready([a, b, c])],
    );

    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should report a failure when they cannot load',
      setUp: () => when(() => getCovers(any())).thenThrow(Exception('Network error')),
      build: build,
      act: (cubit) => cubit.load('a1'),
      skip: 1,
      expect: () => [isA<AlbumCoversState>().having((s) => s.status, 'status', AlbumCoversStatus.failure)],
    );

    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should remove a cover and put it back in its place with undo',
      build: build,
      seed: () => ready([a, b, c]),
      act: (cubit) => cubit
        ..remove('b')
        ..undoRemove(),
      expect: () => [
        isA<AlbumCoversState>()
            .having(ids, 'covers', ['a', 'c'])
            .having((s) => s.lastRemoved, 'last removed', (b, 1))
            .having((s) => s.isDirty, 'dirty', isTrue),
        isA<AlbumCoversState>()
            .having(ids, 'covers', ['a', 'b', 'c'])
            .having((s) => s.lastRemoved, 'last removed', isNull)
            .having((s) => s.isDirty, 'dirty', isFalse),
      ],
    );

    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should reorder like ReorderableListView (moving down counts the item)',
      build: build,
      seed: () => ready([a, b, c]),
      act: (cubit) => cubit
        ..reorder(0, 3)
        ..reorder(2, 0),
      expect: () => [
        isA<AlbumCoversState>().having(ids, 'covers', ['b', 'c', 'a']),
        isA<AlbumCoversState>().having(ids, 'covers', ['a', 'b', 'c']),
      ],
    );

    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should ignore moves to the same place',
      build: build,
      seed: () => ready([a, b, c]),
      act: (cubit) => cubit.reorder(1, 2),
      expect: () => const <AlbumCoversState>[],
    );

    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should only close when nothing changed',
      build: build,
      seed: () => ready([a, b, c]),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<AlbumCoversState>()
            .having((s) => s.status, 'status', AlbumCoversStatus.saved)
            .having((s) => s.changesSaved, 'saved', isFalse),
      ],
      verify: (_) => verifyNever(() => setCovers(folderId: any(named: 'folderId'), orderedFileIds: any(named: 'orderedFileIds'))),
    );

    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should save the final order and tell the album changed',
      setUp: () => when(() => setCovers(folderId: 'a1', orderedFileIds: ['c', 'a']))
          .thenAnswer((_) async => [cover('c', 0), cover('a', 1)]),
      build: build,
      seed: () => ready([c, a]),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<AlbumCoversState>().having((s) => s.status, 'status', AlbumCoversStatus.saving),
        isA<AlbumCoversState>()
            .having((s) => s.status, 'status', AlbumCoversStatus.saved)
            .having((s) => s.changesSaved, 'saved', isTrue)
            .having(ids, 'covers', ['c', 'a']),
      ],
    );

    test('should fire CoversChangedEvent after saving', () async {
      // Arrange
      when(() => setCovers(folderId: any(named: 'folderId'), orderedFileIds: any(named: 'orderedFileIds')))
          .thenAnswer((_) async => const []);
      final fired = <CoversChangedEvent>[];
      eventBus.on<CoversChangedEvent>().listen(fired.add);
      final cubit = build()..emit(ready(const []));

      // Act
      await cubit.save();
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(fired.single.folderIds, ['a1']);
    });

    blocTest<AlbumCoversCubit, AlbumCoversState>(
      'should keep the changes and show the error when saving fails',
      setUp: () => when(() => setCovers(folderId: any(named: 'folderId'), orderedFileIds: any(named: 'orderedFileIds')))
          .thenThrow(Exception('Network error')),
      build: build,
      seed: () => ready([a]),
      act: (cubit) => cubit.save(),
      skip: 1,
      expect: () => [
        isA<AlbumCoversState>()
            .having((s) => s.status, 'status', AlbumCoversStatus.ready)
            .having(ids, 'covers', ['a'])
            .having((s) => s.failure, 'failure', isNotNull),
      ],
    );
  });
}
