import 'dart:io';

import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/current_user_id.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/register_local_albums_use_case.dart';

/// Whether «Tus álbumes» is shown (ROADMAP-local-albums.md): once per account and device, after the onboarding, or
/// at the first start after the update for the accounts that already went through it. Answers the albums to review,
/// or null when there is nothing to decide:
/// - not on Android (iOS, for now) or without access to the photos;
/// - already reviewed;
/// - no album would be imported as an album (an empty gallery, or only the camera and screenshots): it is marked as
///   reviewed, and the albums that appear later follow the rule of the new albums.
class CheckLocalAlbumsReviewUseCase {
  final LocalAlbumsRepository _repository;
  final RegisterLocalAlbumsUseCase _registerLocalAlbums;
  final PermissionService _permissionService;
  final AuthRepository _authRepository;
  final bool _supported;

  CheckLocalAlbumsReviewUseCase(this._repository, this._registerLocalAlbums, this._permissionService,
      this._authRepository, {bool? supported})
      : _supported = supported ?? Platform.isAndroid;

  Future<List<LocalAlbum>?> call() async {
    if (!_supported) return null;
    final userId = await currentUserId(_authRepository);
    if (userId == null || await _repository.isReviewed(userId)) return null;
    if (!await _permissionService.isGranted(AppPermission.photos)) return null;

    final albums = await _registerLocalAlbums();
    if (!albums.any((album) => album.mode == LocalAlbumMode.album)) {
      await _repository.markReviewed(userId);
      return null;
    }
    return albums;
  }
}
