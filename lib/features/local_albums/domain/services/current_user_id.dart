import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';

/// The id of the account with a session, or null when it is not known.
Future<String?> currentUserId(AuthRepository authRepository) async {
  try {
    final user = await authRepository.getCurrentUser();
    return user == null || user.id.isEmpty ? null : user.id;
  } catch (_) {
    return null;
  }
}
