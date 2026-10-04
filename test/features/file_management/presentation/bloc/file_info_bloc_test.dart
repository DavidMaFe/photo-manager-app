import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_file_info_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_state.dart';

class MockGetFileInfoUseCase extends Mock implements GetFileInfoUseCase {}

void main() {
  late MockGetFileInfoUseCase useCase;

  setUp(() => useCase = MockGetFileInfoUseCase());

  const info = FileInfo(id: '42', type: FileType.image, status: FileStatus.managed, deviceName: 'Pixel 8');

  group('FileInfoBloc', () {
    test('should start loading', () {
      expect(FileInfoBloc(getFileInfoUseCase: useCase).state, const FileInfoLoading());
    });

    blocTest<FileInfoBloc, FileInfoState>(
      'should emit [loading, loaded] when the info loads',
      setUp: () => when(() => useCase('42')).thenAnswer((_) async => info),
      build: () => FileInfoBloc(getFileInfoUseCase: useCase),
      act: (bloc) => bloc.add(const LoadFileInfo('42')),
      expect: () => [const FileInfoLoading(), const FileInfoLoaded(info)],
    );

    blocTest<FileInfoBloc, FileInfoState>(
      'should emit an error with a failure when loading fails',
      setUp: () => when(() => useCase('42')).thenThrow(Exception('Network error')),
      build: () => FileInfoBloc(getFileInfoUseCase: useCase),
      act: (bloc) => bloc.add(const LoadFileInfo('42')),
      expect: () => [const FileInfoLoading(), isA<FileInfoError>()],
    );

    blocTest<FileInfoBloc, FileInfoState>(
      'should load again after an error (retry)',
      setUp: () => when(() => useCase('42')).thenAnswer((_) async => info),
      build: () => FileInfoBloc(getFileInfoUseCase: useCase),
      seed: () => const FileInfoLoaded(FileInfo(id: 'old', type: FileType.image, status: FileStatus.managed)),
      act: (bloc) => bloc.add(const LoadFileInfo('42')),
      expect: () => [const FileInfoLoading(), const FileInfoLoaded(info)],
    );
  });
}
