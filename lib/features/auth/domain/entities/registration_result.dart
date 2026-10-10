import 'package:photo_manager_app/features/auth/domain/entities/user.dart';

/// Registered user and the 24 words of the recovery key, shown to the user once registered.
class RegistrationResult {
  final User user;
  final List<String> recoveryWords;

  const RegistrationResult({required this.user, required this.recoveryWords});
}
