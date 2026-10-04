import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_file_info_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_state.dart';


/// Properties of one file, for the properties sheet.
///
/// No minimum loading time: the sheet shows the known properties right away
/// and only the extra rows wait for this bloc.
class FileInfoBloc extends Bloc<FileInfoEvent, FileInfoState> {

  final GetFileInfoUseCase getFileInfoUseCase;

  FileInfoBloc({required this.getFileInfoUseCase}) : super(const FileInfoLoading()) {
    on<LoadFileInfo>(_onLoadFileInfo);
  }

  Future<void> _onLoadFileInfo(LoadFileInfo event, Emitter<FileInfoState> emit) async {
    emit(const FileInfoLoading());
    try {
      final info = await getFileInfoUseCase(event.fileId);
      emit(FileInfoLoaded(info));
    } catch (e) {
      emit(FileInfoError(ErrorHandler.handleError(e)));
    }
  }
}
