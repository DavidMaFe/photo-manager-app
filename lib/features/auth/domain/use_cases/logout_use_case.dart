import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';


/// Logs out. [onLogout] cleans what other features keep for the session (reminders, exported files...).
class LogoutUseCase {

  final AuthRepository _authRepository;
  final List<Future<void> Function()> _onLogout;

  LogoutUseCase(this._authRepository, {List<Future<void> Function()> onLogout = const []}) : _onLogout = onLogout;

  Future<void> call() async {
    await _authRepository.logout();
    for (final cleanup in _onLogout) {
      try {
        await cleanup();
      } catch (_) {
        // A failed cleanup must not keep the user logged in
      }
    }
  }
}
