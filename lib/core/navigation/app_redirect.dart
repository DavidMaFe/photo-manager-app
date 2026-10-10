import 'package:photo_manager_app/core/navigation/route_names.dart';

/// What the redirect needs to know about the session and the onboarding.
class AppRedirectStatus {
  final bool isLoading;
  final bool isCheckingOnboarding;
  final bool isOnboardingRequired;
  final bool isAuthenticated;
  final bool isRecoveryPhrasePending;
  final bool isLegalAcceptancePending;
  final bool isAccountLocked;

  const AppRedirectStatus({
    this.isLoading = false,
    this.isCheckingOnboarding = false,
    this.isOnboardingRequired = false,
    this.isAuthenticated = false,
    this.isRecoveryPhrasePending = false,
    this.isLegalAcceptancePending = false,
    this.isAccountLocked = false,
  });
}

/// Where the router sends the user (null: where they are going). Kept apart from GoRouter so it can be tested.
class AppRedirect {
  const AppRedirect._();

  static String? resolve(AppRedirectStatus status, String location) {
    final isGoingToLogin = location == RoutePaths.login;
    final isGoingToRegister = location == RoutePaths.register;
    final isGoingToPasswordReset = location == RoutePaths.requestPasswordReset ||
        location == RoutePaths.validateResetCode ||
        location == RoutePaths.resetPassword;
    final isGoingToOnboarding = location == RoutePaths.onboarding;
    final isGoingToRecoveryPhrase =
        location == RoutePaths.recoveryPhrase || location == RoutePaths.confirmRecoveryPhrase;
    final isGoingToLockedAccount = location == RoutePaths.lockedAccount;
    final isGoingToLegalAcceptance = location == RoutePaths.legalAcceptance;
    final isGoingToLegal = location == RoutePaths.legal || location.startsWith('${RoutePaths.legal}/');
    final isAuthenticated = status.isAuthenticated;

    if (status.isLoading || status.isCheckingOnboarding) {
      return null;
    }

    // The information pages and the legal texts can be read in any state, with or without a session
    if (isGoingToLegal) {
      return null;
    }

    // Just registered: show and confirm the 24 words before anything else
    if (status.isRecoveryPhrasePending) {
      return isGoingToRecoveryPhrase ? null : RoutePaths.recoveryPhrase;
    }

    // The terms of use and the privacy policy in force are accepted before anything else
    if (status.isLegalAcceptancePending) {
      return isGoingToLegalAcceptance ? null : RoutePaths.legalAcceptance;
    }

    // Locked account: the locked account page (and the words of a new key) before the gallery
    if (status.isAccountLocked) {
      return isGoingToLockedAccount || isGoingToRecoveryPhrase ? null : RoutePaths.lockedAccount;
    }

    // Those flows are over once the session starts
    if (isAuthenticated && (isGoingToRecoveryPhrase || isGoingToLockedAccount || isGoingToLegalAcceptance)) {
      return status.isOnboardingRequired ? RoutePaths.onboarding : RoutePaths.home;
    }

    if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister && !isGoingToPasswordReset) {
      return RoutePaths.login;
    }

    // Authenticated user trying to access auth pages: home, or the onboarding if it is required
    if (isAuthenticated && (isGoingToLogin || isGoingToRegister || isGoingToPasswordReset)) {
      return status.isOnboardingRequired ? RoutePaths.onboarding : RoutePaths.home;
    }

    // Authenticated user who needs onboarding but is not going there
    if (isAuthenticated && status.isOnboardingRequired && !isGoingToOnboarding) {
      return RoutePaths.onboarding;
    }

    // Authenticated user who completed onboarding but is on onboarding page
    if (isAuthenticated && !status.isOnboardingRequired && isGoingToOnboarding) {
      return RoutePaths.home;
    }

    return null;
  }
}
