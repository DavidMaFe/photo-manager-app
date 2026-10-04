import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/folders/domain/entities/album_cover.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_change.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_target.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_covers.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/apply_cover_changes_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_cover_targets_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/cover_picker/cover_picker_cubit.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/cover_picker/cover_picker_state.dart';

class MockGetCoverTargetsUseCase extends Mock implements GetCoverTargetsUseCase {}

class MockApplyCoverChangesUseCase extends Mock implements ApplyCoverChangesUseCase {}

void main() {
  late MockGetCoverTargetsUseCase getTargets;
  late MockApplyCoverChangesUseCase applyChanges;
  late AppEventBus eventBus;

  setUp(() {
    getTargets = MockGetCoverTargetsUseCase();
    applyChanges = MockApplyCoverChangesUseCase();
    eventBus = AppEventBus();
  });

  AlbumCover cover(String id, int position) =>
      AlbumCover(fileId: id, position: position, sourceFolderId: 'x', sourceFolderName: 'X');

  CoverTarget target(String id, List<String> covers, {int depth = 0, bool direct = false}) => CoverTarget(
        folderId: id,
        name: id,
        depth: depth,
        containsDirectly: direct,
        covers: [for (var i = 0; i < covers.length; i++) cover(covers[i], i)],
      );

  // root: p1 is a cover; beach: full with others; sunsets: empty, where p1 is.
  final targets = [
    target('root', ['p1', 'c1']),
    target('beach', ['c1', 'c2', 'c3'], depth: 1),
    target('sunsets', [], depth: 2, direct: true),
  ];

  CoverPickerCubit build() => CoverPickerCubit(
        getCoverTargetsUseCase: getTargets,
        applyCoverChangesUseCase: applyChanges,
        eventBus: eventBus,
      );

  CoverPickerState ready({List<String> fileIds = const ['p1'], Set<String>? checked}) => CoverPickerState(
        status: CoverPickerStatus.ready,
        fileIds: fileIds,
        targets: targets,
        checked: checked ?? {'root'},
      );

  CoverTarget byId(String id) => targets.firstWhere((t) => t.folderId == id);

  group('CoverPickerCubit', () {
    group('load', () {
      blocTest<CoverPickerCubit, CoverPickerState>(
        'should tick the albums the photo already is a cover of',
        setUp: () => when(() => getTargets(['p1'])).thenAnswer((_) async => targets),
        build: build,
        act: (cubit) => cubit.load(['p1']),
        expect: () => [const CoverPickerState(fileIds: ['p1']), ready()],
      );

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should report photos without a common album',
        setUp: () => when(() => getTargets(any())).thenAnswer((_) async => const []),
        build: build,
        act: (cubit) => cubit.load(['p1', 'p2']),
        skip: 1,
        expect: () => [isA<CoverPickerState>().having((s) => s.status, 'status', CoverPickerStatus.noSharedAlbum)],
      );

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should report a failure when the albums cannot load',
        setUp: () => when(() => getTargets(any())).thenThrow(Exception('Network error')),
        build: build,
        act: (cubit) => cubit.load(['p1']),
        skip: 1,
        expect: () => [
          isA<CoverPickerState>()
              .having((s) => s.status, 'status', CoverPickerStatus.failure)
              .having((s) => s.failure, 'failure', isNotNull),
        ],
      );
    });

    group('rows', () {
      test('should describe what will happen to each album', () {
        final state = ready(checked: {'beach', 'sunsets'});

        expect(state.rowStatus(byId('root')), CoverRowStatus.willRemove);
        expect(state.rowStatus(byId('beach')), CoverRowStatus.needsReplacement);
        expect(state.rowStatus(byId('sunsets')), CoverRowStatus.willAdd);
        expect(state.coverCountAfterAdding(byId('sunsets')), 1);
        expect(ready().rowStatus(byId('root')), CoverRowStatus.alreadyCover);
        expect(ready().rowStatus(byId('sunsets')), CoverRowStatus.unchanged);
      });

      test('should count the changes and wait for replacements before saving', () {
        final state = ready(checked: {'beach', 'sunsets'});

        expect(state.changeCount, 3);
        expect(state.canSave, isFalse);
        expect(state.copyWith(replacements: {'beach': ['c2']}).canSave, isTrue);
        expect(ready().canSave, isFalse);
      });

      test('should preview the covers each album will have', () {
        final state = ready(checked: {'beach', 'sunsets'}).copyWith(replacements: {'beach': ['c2']});

        expect(state.previewCovers(byId('root')), ['c1']);
        expect(state.previewCovers(byId('beach')), ['c1', 'p1', 'c3']);
        expect(state.previewCovers(byId('sunsets')), ['p1']);
      });

      test('should build one change list per photo', () {
        final state = ready(checked: {'beach', 'sunsets'}).copyWith(replacements: {'beach': ['c2']});

        expect(state.changesByFile(), {
          'p1': [
            const CoverChange.remove('root'),
            const CoverChange.replace('beach', 'c2'),
            const CoverChange.add('sunsets'),
          ],
        });
      });

      test('should add what fits and replace the rest for several photos', () {
        // root has one free place: p2 is added, p3 replaces c1.
        final state = CoverPickerState(
          status: CoverPickerStatus.ready,
          fileIds: const ['p2', 'p3'],
          targets: targets,
          checked: const {'root'},
          replacements: const {'root': ['c1']},
        );

        expect(state.replacementsNeeded(byId('root')), 1);
        expect(state.replaceableCovers(byId('root')), ['p1', 'c1']);
        expect(state.changesByFile(), {
          'p2': [const CoverChange.add('root')],
          'p3': [const CoverChange.replace('root', 'c1')],
        });
        expect(state.previewCovers(byId('root')), ['p1', 'p3', 'p2']);
      });
    });

    group('toggle', () {
      blocTest<CoverPickerCubit, CoverPickerState>(
        'should tick and untick an album, forgetting its replacements',
        build: build,
        seed: () => ready(checked: {'root', 'beach'}).copyWith(replacements: {'beach': ['c2']}),
        act: (cubit) => cubit.toggle('beach'),
        expect: () => [ready()],
      );

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should not change anything while loading',
        build: build,
        act: (cubit) => cubit.toggle('beach'),
        expect: () => const <CoverPickerState>[],
      );
    });

    group('chooseReplacement', () {
      blocTest<CoverPickerCubit, CoverPickerState>(
        'should work as a radio group when one replacement is needed',
        build: build,
        seed: () => ready(checked: {'root', 'beach'}),
        act: (cubit) => cubit
          ..chooseReplacement('beach', 'c2')
          ..chooseReplacement('beach', 'c3'),
        expect: () => [
          ready(checked: {'root', 'beach'}).copyWith(replacements: {'beach': ['c2']}),
          ready(checked: {'root', 'beach'}).copyWith(replacements: {'beach': ['c3']}),
        ],
      );

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should un-choose a chosen cover',
        build: build,
        seed: () => ready(checked: {'root', 'beach'}).copyWith(replacements: {'beach': ['c2']}),
        act: (cubit) => cubit.chooseReplacement('beach', 'c2'),
        expect: () => [ready(checked: {'root', 'beach'}).copyWith(replacements: {'beach': []})],
      );

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should ignore albums that need no replacement',
        build: build,
        seed: () => ready(checked: {'root', 'sunsets'}),
        act: (cubit) => cubit.chooseReplacement('sunsets', 'c1'),
        expect: () => const <CoverPickerState>[],
      );
    });

    group('save', () {
      final saved = [FolderCovers(folderId: 'sunsets', covers: [cover('p1', 0)])];

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should save, tell the albums that changed and close',
        setUp: () => when(() => applyChanges(targets: any(named: 'targets'), changesByFile: any(named: 'changesByFile')))
            .thenAnswer((_) async => saved),
        build: build,
        seed: () => ready(checked: {'root', 'sunsets'}),
        act: (cubit) => cubit.save(),
        expect: () => [
          ready(checked: {'root', 'sunsets'}).copyWith(status: CoverPickerStatus.saving),
          ready(checked: {'root', 'sunsets'}).copyWith(status: CoverPickerStatus.saved, savedFolders: saved),
        ],
        verify: (_) => verify(() => applyChanges(
              targets: targets,
              changesByFile: {'p1': [const CoverChange.add('sunsets')]},
            )).called(1),
      );

      test('should fire CoversChangedEvent with the changed albums', () async {
        // Arrange
        when(() => applyChanges(targets: any(named: 'targets'), changesByFile: any(named: 'changesByFile')))
            .thenAnswer((_) async => saved);
        final fired = <CoversChangedEvent>[];
        eventBus.on<CoversChangedEvent>().listen(fired.add);
        final cubit = build()..emit(ready(checked: {'sunsets'}));

        // Act
        await cubit.save();
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(fired.single.folderIds, ['root', 'sunsets']);
      });

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should stay open with the error when saving fails',
        setUp: () => when(() => applyChanges(targets: any(named: 'targets'), changesByFile: any(named: 'changesByFile')))
            .thenThrow(const ValidationFailure(code: 'FOLDER_COVERS_LIMIT_EXCEEDED')),
        build: build,
        seed: () => ready(checked: {'root', 'sunsets'}),
        act: (cubit) => cubit.save(),
        skip: 1,
        expect: () => [
          isA<CoverPickerState>()
              .having((s) => s.status, 'status', CoverPickerStatus.ready)
              .having((s) => s.failure, 'failure', isA<ValidationFailure>()),
        ],
      );

      blocTest<CoverPickerCubit, CoverPickerState>(
        'should not save without changes',
        build: build,
        seed: () => ready(),
        act: (cubit) => cubit.save(),
        expect: () => const <CoverPickerState>[],
      );
    });
  });
}
