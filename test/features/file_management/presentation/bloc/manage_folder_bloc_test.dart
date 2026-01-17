import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_folders_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';

class MockGetFoldersUseCase extends Mock implements GetFoldersUseCase {}
class MockAppEventBus extends Mock implements AppEventBus {}

void main() {
  late MockGetFoldersUseCase mockUseCase;
  late MockAppEventBus mockEventBus;

  setUp(() {
    mockUseCase = MockGetFoldersUseCase();
    mockEventBus = MockAppEventBus();

    when(() => mockEventBus.on<FolderUpdatedEvent>())
        .thenAnswer((_) => const Stream.empty());
  });

  group('ManageFolderBloc', () {
    final testDate = DateTime(2024, 1, 15);

    final folders = [
      ManageFolder(
        id: 'folder-1',
        name: 'Vacation',
        fileCount: 42,
        createdAt: testDate,
      ),
      ManageFolder(
        id: 'folder-2',
        name: 'Work',
        fileCount: 15,
        createdAt: testDate.add(const Duration(days: 1)),
      ),
    ];

    test('initial state is ManageFolderStarting', () {
      final bloc = ManageFolderBloc(
        getFoldersUseCase: mockUseCase,
        eventBus: mockEventBus,
      );

      expect(bloc.state, const ManageFolderStarting());
      bloc.close();
    });

    group('LoadFolders', () {
      blocTest<ManageFolderBloc, ManageFolderState>(
        'emits [Loading, Loaded] when folders are loaded successfully',
        setUp: () {
          when(() => mockUseCase.call()).thenAnswer((_) async => folders);
        },
        build: () => ManageFolderBloc(
          getFoldersUseCase: mockUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          const ManageFoldersLoading(),
          ManageFoldersLoaded(folders: folders),
        ],
        verify: (_) {
          verify(() => mockUseCase.call()).called(1);
        },
      );

      blocTest<ManageFolderBloc, ManageFolderState>(
        'emits [Loading, Loaded] with empty list when no folders',
        setUp: () {
          when(() => mockUseCase.call()).thenAnswer((_) async => []);
        },
        build: () => ManageFolderBloc(
          getFoldersUseCase: mockUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          const ManageFoldersLoading(),
          const ManageFoldersLoaded(folders: []),
        ],
      );

      blocTest<ManageFolderBloc, ManageFolderState>(
        'emits [Loading, Error] when use case throws exception',
        setUp: () {
          when(() => mockUseCase.call()).thenThrow(Exception('Network error'));
        },
        build: () => ManageFolderBloc(
          getFoldersUseCase: mockUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          const ManageFoldersLoading(),
          isA<ManageFolderError>(),
        ],
      );

      blocTest<ManageFolderBloc, ManageFolderState>(
        'emits error with failure object',
        setUp: () {
          when(() => mockUseCase.call()).thenThrow(Exception('Test error'));
        },
        build: () => ManageFolderBloc(
          getFoldersUseCase: mockUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          const ManageFoldersLoading(),
          isA<ManageFolderError>()
              .having((s) => s.failure, 'failure', isA<Failure>()),
        ],
      );

      blocTest<ManageFolderBloc, ManageFolderState>(
        'does not emit loading when already loaded (silent refresh)',
        setUp: () {
          when(() => mockUseCase.call()).thenAnswer((_) async => folders);
        },
        build: () => ManageFolderBloc(
          getFoldersUseCase: mockUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => ManageFoldersLoaded(folders: folders),
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [],
        verify: (_) {
          verify(() => mockUseCase.call()).called(1);
        },
      );

      blocTest<ManageFolderBloc, ManageFolderState>(
        'handles multiple folders',
        setUp: () {
          final manyFolders = List.generate(
            10,
                (i) => ManageFolder(
              id: 'folder-$i',
              name: 'Folder $i',
              fileCount: i * 10,
              createdAt: testDate.add(Duration(days: i)),
            ),
          );
          when(() => mockUseCase.call()).thenAnswer((_) async => manyFolders);
        },
        build: () => ManageFolderBloc(
          getFoldersUseCase: mockUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          const ManageFoldersLoading(),
          isA<ManageFoldersLoaded>()
              .having((s) => s.folders.length, 'folder count', 10),
        ],
      );

      blocTest<ManageFolderBloc, ManageFolderState>(
        'can reload folders multiple times',
        setUp: () {
          when(() => mockUseCase.call()).thenAnswer((_) async => folders);
        },
        build: () => ManageFolderBloc(
          getFoldersUseCase: mockUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) {
          bloc.add(const LoadFolders());
          bloc.add(const LoadFolders());
        },
        expect: () => [
          const ManageFoldersLoading(),
          ManageFoldersLoaded(folders: folders),
        ],
        verify: (_) {
          verify(() => mockUseCase.call()).called(2);
        },
      );
    });
  });
}
