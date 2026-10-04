import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';


abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}


/// Marks or unmarks [files] (their current value is the one to restore on failure).
class SetFavorites extends FavoritesEvent {

  final List<GalleryFile> files;
  final bool favorite;

  const SetFavorites({required this.files, required this.favorite});

  @override
  List<Object?> get props => [files, favorite];
}
