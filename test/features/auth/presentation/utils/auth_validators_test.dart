import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';
import 'package:photo_manager_app/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('AuthValidators', () {
    group('email', () {
      test('should require a value', () {
        expect(AuthValidators.email(l10n, '  '), l10n.errorEmailRequired);
        expect(AuthValidators.email(l10n, null), l10n.errorEmailRequired);
      });

      test('should reject emails without @ or dot', () {
        expect(AuthValidators.email(l10n, 'a.b'), l10n.errorInvalidEmail);
        expect(AuthValidators.email(l10n, 'a@b'), l10n.errorInvalidEmail);
      });

      test('should accept a valid email', () {
        expect(AuthValidators.email(l10n, 'a@b.com'), isNull);
      });
    });

    group('password', () {
      test('should require a non-blank value', () {
        expect(AuthValidators.password(l10n, ' '), l10n.errorPasswordRequired);
        expect(AuthValidators.password(l10n, 'x'), isNull);
      });
    });

    group('confirmation', () {
      test('should require a value and match the password', () {
        expect(AuthValidators.confirmation(l10n, '', 'abc'), l10n.errorConfirmPasswordRequired);
        expect(AuthValidators.confirmation(l10n, 'abd', 'abc'), l10n.errorPasswordsDoNotMatch);
        expect(AuthValidators.confirmation(l10n, 'abc', 'abc'), isNull);
      });
    });
  });
}
