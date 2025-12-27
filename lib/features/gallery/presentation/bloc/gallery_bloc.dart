import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_files_use_case.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';

import '../../domain/enums/file_filter.dart';


class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {

  final GetFilesUseCase getFilesUseCase;
  static const int _pageSize = 50;

  GalleryBloc({required this.getFilesUseCase}) : super(const GalleryStarting()) {
    on<LoadGallery>(_onLoadGallery);
    on<LoadMoreFiles>(_onLoadMoreFiles);
    on<RefreshGallery>(_onRefreshGallery);
  }

  Future<void> _onLoadGallery(LoadGallery event, Emitter<GalleryState> emit) async {

    emit(GalleryLoading(filter: event.filter));

    try {

      final result = await getFilesUseCase(page: 0, pageSize: _pageSize, filter: event.filter);
      emit(GalleryLoaded(files: result.files, hasNext: result.hasNext,
          currentPage: result.currentPage, filter: event.filter));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(GalleryError(failure));
    }
  }

  Future<void> _onLoadMoreFiles(LoadMoreFiles event, Emitter<GalleryState> emit) async {

    if (state is! GalleryLoaded) return;

    final currentState = state as GalleryLoaded;
    if(!currentState.hasNext) return;

    emit(GalleryLoadingMore(files: currentState.files,
        currentPage: currentState.currentPage, filter:  currentState.filter));

    try {

      final nextPage = currentState.currentPage + 1;
      final result = await getFilesUseCase(page: nextPage, pageSize: _pageSize, filter: currentState.filter);
      final updatedFiles = [
        ...currentState.files,
        ...result.files
      ];

      emit(GalleryLoaded(files: updatedFiles, hasNext: result.hasNext,
          currentPage: nextPage, filter: currentState.filter));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(GalleryError(failure));
    }
  }

  Future<void> _onRefreshGallery(RefreshGallery event, Emitter<GalleryState> emit) async {

    FileFilter currentFilter = FileFilter.all;

    if (state is GalleryLoaded) {
      currentFilter = (state as GalleryLoaded).filter;
    } else if (state is GalleryLoadingMore) {
      currentFilter = (state as GalleryLoadingMore).filter;
    }

    emit(GalleryLoading(filter: currentFilter));

    try {

      final result = await getFilesUseCase(page: 0, pageSize: _pageSize, filter: currentFilter);
      emit(GalleryLoaded(files: result.files, hasNext: result.hasNext,
          currentPage: result.currentPage, filter: currentFilter));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(GalleryError(failure));
    }
  }
}