import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/manage_files_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';

class MockManageFilesUseCase extends Mock implements ManageFilesUseCase {}
class MockAppEventBus extends Mock implements AppEventBus {}

void main() {

  setUpAll(() {
    registerFallbackValue(
        ManageAction(
            serverAction: ServerAction.save,
            keepOnDevice: true
        )
    );
  });

  late FileManagementBloc bloc;
  late MockManageFilesUseCase mockUseCase;
  late MockAppEventBus mockEventBus;

  setUp(() {
    mockUseCase = MockManageFilesUseCase();
    mockEventBus = MockAppEventBus();
    bloc = FileManagementBloc(
      manageFilesUseCase: mockUseCase,
      eventBus: mockEventBus,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FileManagementBloc', () {
    const fileIds = ['file-1', 'file-2', 'file-3'];
    const action = ManageAction(
      serverAction: ServerAction.save,
      keepOnDevice: true,
    );

    test('initial state is FileManagementStarting', () {
      expect(bloc.state, const FileManagementStarting());
    });

    group('ManagedFilesRequested', () {
      blocTest<FileManagementBloc, FileManagementState>(
        'emits [Loading, Success] when all files succeed',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenAnswer((_) async => []); // Empty list means all succeeded
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: action,
        )),
        expect: () => [
          const FileManagementLoading(),
          const FileManagementSuccess(
            message: '3 files managed',
            processedCount: 3,
          ),
        ],
        verify: (_) {
          verify(() => mockUseCase.call(fileIds, action)).called(1);
        },
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'emits success with singular message for single file',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenAnswer((_) async => []);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: ['file-1'],
          action: action,
        )),
        expect: () => [
          const FileManagementLoading(),
          const FileManagementSuccess(
            message: 'Files managed correctly',
            processedCount: 1,
          ),
        ],
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'emits [Loading, PartialSuccess] when some files fail',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenAnswer((_) async => ['file-2']); // One failed
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: action,
        )),
        expect: () => [
          const FileManagementLoading(),
          const FileManagementPartialSuccess(
            successCount: 2,
            failedCount: 1,
            failedFiles: ['file-2'],
          ),
        ],
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'emits [Loading, Error] when use case throws exception',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: action,
        )),
        expect: () => [
          const FileManagementLoading(),
          isA<FileManagementError>(),
        ],
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'works with delete action',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenAnswer((_) async => []);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: ManageAction(
            serverAction: ServerAction.delete,
            keepOnDevice: false,
          ),
        )),
        expect: () => [
          const FileManagementLoading(),
          const FileManagementSuccess(
            message: '3 files managed',
            processedCount: 3,
          ),
        ],
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'works with folder action',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenAnswer((_) async => []);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: ManageAction(
            serverAction: ServerAction.folder,
            folderId: 'folder-123',
            keepOnDevice: true,
          ),
        )),
        expect: () => [
          const FileManagementLoading(),
          const FileManagementSuccess(
            message: '3 files managed',
            processedCount: 3,
          ),
        ],
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'works with newFolder action',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenAnswer((_) async => []);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: ManageAction(
            serverAction: ServerAction.newFolder,
            folderName: 'New Folder',
            keepOnDevice: true,
          ),
        )),
        expect: () => [
          const FileManagementLoading(),
          const FileManagementSuccess(
            message: '3 files managed',
            processedCount: 3,
          ),
        ],
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'handles all files failed scenario',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenAnswer((_) async => fileIds); // All failed
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: action,
        )),
        expect: () => [
          const FileManagementLoading(),
          const FileManagementPartialSuccess(
            successCount: 0,
            failedCount: 3,
            failedFiles: fileIds,
          ),
        ],
      );

      blocTest<FileManagementBloc, FileManagementState>(
        'emits error with failure object',
        setUp: () {
          when(() => mockUseCase.call(any(), any()))
              .thenThrow(Exception('Test error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const ManagedFilesRequested(
          fileIds: fileIds,
          action: action,
        )),
        expect: () => [
          const FileManagementLoading(),
          isA<FileManagementError>()
              .having((s) => s.failure, 'failure', isA<Failure>()),
        ],
      );
    });
  });
}
