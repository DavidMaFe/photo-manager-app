import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/navigation/app_redirect.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';

void main() {
  const loggedOut = AppRedirectStatus();
  const loggedIn = AppRedirectStatus(isAuthenticated: true);

  group('AppRedirect', () {
    group('without a session', () {
      test('should send to the login from a private page', () {
        expect(AppRedirect.resolve(loggedOut, RoutePaths.home), RoutePaths.login);
      });

      test('should let the user register and reset the password', () {
        for (final location in [RoutePaths.login, RoutePaths.register, RoutePaths.requestPasswordReset,
            RoutePaths.validateResetCode, RoutePaths.resetPassword]) {
          expect(AppRedirect.resolve(loggedOut, location), isNull, reason: location);
        }
      });

      test('should let the user read the information and the legal texts', () {
        expect(AppRedirect.resolve(loggedOut, RoutePaths.legal), isNull);
        expect(AppRedirect.resolve(loggedOut, RoutePaths.legalDocumentOf('terms')), isNull);
        expect(AppRedirect.resolve(loggedOut, RoutePaths.legalDocumentOf('privacy')), isNull);
      });

      test('should not take the acceptance page for a legal text', () {
        expect(AppRedirect.resolve(loggedOut, RoutePaths.legalAcceptance), RoutePaths.login);
      });
    });

    group('while loading', () {
      test('should not redirect', () {
        expect(AppRedirect.resolve(const AppRedirectStatus(isLoading: true), RoutePaths.home), isNull);
        expect(AppRedirect.resolve(const AppRedirectStatus(isCheckingOnboarding: true), RoutePaths.home), isNull);
      });
    });

    group('after registering', () {
      const pending = AppRedirectStatus(isRecoveryPhrasePending: true);

      test('should keep the user on the 24 words until they are confirmed', () {
        expect(AppRedirect.resolve(pending, RoutePaths.home), RoutePaths.recoveryPhrase);
        expect(AppRedirect.resolve(pending, RoutePaths.recoveryPhrase), isNull);
        expect(AppRedirect.resolve(pending, RoutePaths.confirmRecoveryPhrase), isNull);
      });

      test('should let the user read about the 24 words', () {
        expect(AppRedirect.resolve(pending, RoutePaths.legalDocumentOf('recovery-words')), isNull);
      });
    });

    group('legal acceptance pending', () {
      const pending = AppRedirectStatus(isLegalAcceptancePending: true, isAccountLocked: false);

      test('should ask for the acceptance before the gallery and the locked account', () {
        expect(AppRedirect.resolve(pending, RoutePaths.home), RoutePaths.legalAcceptance);
        expect(AppRedirect.resolve(pending, RoutePaths.lockedAccount), RoutePaths.legalAcceptance);
        expect(AppRedirect.resolve(pending, RoutePaths.legalAcceptance), isNull);
      });

      test('should let the user read the terms and the privacy policy before accepting', () {
        expect(AppRedirect.resolve(pending, RoutePaths.legalDocumentOf('terms')), isNull);
      });
    });

    group('locked account', () {
      const locked = AppRedirectStatus(isAccountLocked: true);

      test('should show the locked account page before the gallery', () {
        expect(AppRedirect.resolve(locked, RoutePaths.home), RoutePaths.lockedAccount);
        expect(AppRedirect.resolve(locked, RoutePaths.lockedAccount), isNull);
        expect(AppRedirect.resolve(locked, RoutePaths.recoveryPhrase), isNull);
      });
    });

    group('with a session', () {
      test('should leave the finished flows', () {
        for (final location in [RoutePaths.recoveryPhrase, RoutePaths.lockedAccount, RoutePaths.legalAcceptance,
            RoutePaths.login]) {
          expect(AppRedirect.resolve(loggedIn, location), RoutePaths.home, reason: location);
        }
      });

      test('should let the user read the legal texts from the profile', () {
        expect(AppRedirect.resolve(loggedIn, RoutePaths.legal), isNull);
      });

      test('should send to the onboarding when it is required', () {
        const onboarding = AppRedirectStatus(isAuthenticated: true, isOnboardingRequired: true);

        expect(AppRedirect.resolve(onboarding, RoutePaths.home), RoutePaths.onboarding);
        expect(AppRedirect.resolve(onboarding, RoutePaths.login), RoutePaths.onboarding);
        expect(AppRedirect.resolve(onboarding, RoutePaths.onboarding), isNull);
      });

      test('should leave the onboarding once it is done', () {
        expect(AppRedirect.resolve(loggedIn, RoutePaths.onboarding), RoutePaths.home);
        expect(AppRedirect.resolve(loggedIn, RoutePaths.home), isNull);
      });
    });
  });
}
