import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/current_user_id.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/set_local_album_modes_use_case.dart';

/// «Continuar» on «Tus álbumes»: saves the options the user changed and does not show the page again.
class FinishLocalAlbumsReviewUseCase {
  final SetLocalAlbumModesUseCase _setModes;
  final LocalAlbumsRepository _repository;
  final AuthRepository _authRepository;

  FinishLocalAlbumsReviewUseCase(this._setModes, this._repository, this._authRepository);

  Future<void> call(Map<String, LocalAlbumMode> changes) async {
    if (changes.isNotEmpty) {
      await _setModes(changes);
    }
    final userId = await currentUserId(_authRepository);
    if (userId != null) {
      await _repository.markReviewed(userId);
    }
  }
}
