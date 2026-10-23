import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/finish_local_albums_review_use_case.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/register_local_albums_use_case.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/set_local_album_modes_use_case.dart';
import 'package:photo_manager_app/features/local_albums/presentation/bloc/local_albums_state.dart';

export 'package:photo_manager_app/features/local_albums/presentation/bloc/local_albums_state.dart';

/// The albums of the gallery and their options (ROADMAP-local-albums.md):
/// - «Tus álbumes» ([show], [choose], [finish]): the changes are saved together with «Continuar»;
/// - «Álbumes del móvil» in the backup settings ([load], [change]): each change is saved at once.
class LocalAlbumsCubit extends Cubit<LocalAlbumsState> {
  static const int minimumLoadingDuration = 800;

  final RegisterLocalAlbumsUseCase registerLocalAlbums;
  final SetLocalAlbumModesUseCase setLocalAlbumModes;
  final FinishLocalAlbumsReviewUseCase finishLocalAlbumsReview;
  final PermissionService permissionService;

  LocalAlbumsCubit({
    required this.registerLocalAlbums,
    required this.setLocalAlbumModes,
    required this.finishLocalAlbumsReview,
    required this.permissionService,
  }) : super(const LocalAlbumsState());

  /// «Tus álbumes», with the albums already registered.
  void show(List<LocalAlbum> albums) {
    emit(LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: _byName(albums)));
  }

  /// Registers what the gallery has now and shows it.
  Future<void> load() async {
    emit(state.copyWith(status: LocalAlbumsStatus.loading));
    final stopwatch = Stopwatch()..start();
    try {
      if (!await permissionService.isGranted(AppPermission.photos)) {
        await _waitForLoading(stopwatch);
        emit(const LocalAlbumsState(status: LocalAlbumsStatus.noPermission));
        return;
      }
      final limited = await permissionService.isPhotoAccessLimited();
      final albums = await registerLocalAlbums();
      await _waitForLoading(stopwatch);
      emit(LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: _byName(albums), limitedAccess: limited));
    } catch (e) {
      await _waitForLoading(stopwatch);
      emit(LocalAlbumsState(status: LocalAlbumsStatus.error, failure: ErrorHandler.handleError(e)));
    }
  }

  Future<void> requestPermission() async {
    if (await permissionService.request(AppPermission.photos)) {
      await load();
    } else {
      await permissionService.openSettings();
    }
  }

  /// A change on «Tus álbumes», saved by [finish].
  void choose(String localAlbumId, LocalAlbumMode mode) {
    final album = state.albums.firstWhere((album) => album.localAlbumId == localAlbumId);
    final changes = Map<String, LocalAlbumMode>.of(state.changes);
    if (album.mode == mode) {
      changes.remove(localAlbumId);
    } else {
      changes[localAlbumId] = mode;
    }
    emit(state.copyWith(changes: changes));
  }

  /// «Continuar» on «Tus álbumes».
  Future<void> finish() async {
    emit(state.copyWith(saving: true));
    try {
      await finishLocalAlbumsReview(state.changes);
      emit(state.copyWith(status: LocalAlbumsStatus.done, saving: false));
    } catch (e) {
      emit(state.copyWith(saving: false, failure: ErrorHandler.handleError(e)));
    }
  }

  /// A change in the backup settings, saved at once; it goes back if the server does not take it.
  Future<void> change(String localAlbumId, LocalAlbumMode mode) async {
    final previous = state;
    emit(state.copyWith(changes: {...state.changes, localAlbumId: mode}, saving: true));
    try {
      final saved = {for (final album in await setLocalAlbumModes({localAlbumId: mode})) album.localAlbumId: album};
      final albums = [
        for (final album in previous.albums)
          saved[album.localAlbumId]?.withAssetCount(album.assetCount) ?? album,
      ];
      emit(state.copyWith(albums: albums, changes: const {}, saving: false));
    } catch (e) {
      emit(previous.copyWith(failure: ErrorHandler.handleError(e)));
    }
  }

  void failureShown() => emit(state.copyWith());

  static List<LocalAlbum> _byName(List<LocalAlbum> albums) =>
      [...albums]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  Future<void> _waitForLoading(Stopwatch stopwatch) async {
    stopwatch.stop();
    final remaining = minimumLoadingDuration - stopwatch.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
  }
}
