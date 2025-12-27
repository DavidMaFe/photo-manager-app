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

  @override
  String toString() => 'LoadGallery (filter: $filter)';
}


class LoadMoreFiles extends GalleryEvent {
  const LoadMoreFiles();

  @override
  String toString() => 'LoadMoreFiles';
}


class RefreshGallery extends GalleryEvent {
  const RefreshGallery();

  @override
  String toString() => 'RefreshGallery';
}