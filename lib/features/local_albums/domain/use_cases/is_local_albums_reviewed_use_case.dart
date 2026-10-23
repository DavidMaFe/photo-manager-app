import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/current_user_id.dart';

/// Whether the account already went through «Tus álbumes» on this device. Until then a background backup applies the
/// default options without telling about the new albums: the page is shown when the app is opened.
class IsLocalAlbumsReviewedUseCase {
  final LocalAlbumsRepository _repository;
  final AuthRepository _authRepository;

  IsLocalAlbumsReviewedUseCase(this._repository, this._authRepository);

  Future<bool> call() async {
    final userId = await currentUserId(_authRepository);
    return userId == null || await _repository.isReviewed(userId);
  }
}
