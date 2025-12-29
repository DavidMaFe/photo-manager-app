import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}


class LoadGallery extends GalleryEvent {
  final FileFilter filter;

  const LoadGallery({this.filter = FileFilter.all});

  @override
  List<Object?> get props => [filter];
}


class LoadMoreFiles extends GalleryEvent {
  const LoadMoreFiles();
}


class RefreshGallery extends GalleryEvent {
  const RefreshGallery();
}


class EnterSelectionMode extends GalleryEvent {
  const EnterSelectionMode();
}


class ExitSelectionMode extends GalleryEvent {
  const ExitSelectionMode();
}


class ToggleFileSelection extends GalleryEvent {
  final String fileId;

  const ToggleFileSelection(this.fileId);

  @override
  List<Object?> get props => [fileId];
}


class SelectAllFiles extends GalleryEvent {
  const SelectAllFiles();
}


class ClearSelection extends GalleryEvent {
  const ClearSelection();
}