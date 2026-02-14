import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/onboarding_notifier.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_helper.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:photo_manager_app/features/onboarding/presentation/widgets/permission_rejection_warning_dialog.dart';
import 'package:photo_manager_app/features/onboarding/presentation/widgets/welcome_permission_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Onboarding page for first-time users
///
/// This page guides users through granting necessary permissions
/// for the app to function properly.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    // Start the onboarding flow when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingBloc>().add(OnboardingStarted(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) async {
          // Handle state changes
          if (state is OnboardingWelcome) {
            // Show welcome dialog
            await _showWelcomeDialog(context, l10n);
          } else if (state is OnboardingRequestingPermissions) {
            // Request permissions
            await _requestPermissions(context, l10n);
          } else if (state is OnboardingPermissionsPartiallyDenied) {
            // Show warning dialog
            await _showRejectionWarningDialog(context, l10n, state);
          } else if (state is OnboardingComplete) {
            // Notify the router notifier that onboarding is done
            sl<OnboardingNotifier>().markOnboardingComplete();
            // Navigate to home
            if (mounted) {
              context.go(RoutePaths.home);
            }
          }
        },
        builder: (context, state) {
          // Show loading indicator while processing
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state is OnboardingRequestingPermissions) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    l10n.processing,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ] else ...[
                  // Show app logo or branding
                  const Icon(
                    Icons.photo_library,
                    size: 100,
                    color: Color(0xFF5D5BE9),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show welcome dialog
  Future<void> _showWelcomeDialog(BuildContext context, AppLocalizations l10n) async {
    final shouldProceed = await WelcomePermissionDialog.show(
      context: context,
      title: l10n.onboardingWelcomeTitle,
      message: l10n.onboardingWelcomeMessage,
      buttonText: l10n.onboardingWelcomeButton,
    );

    if (shouldProceed && mounted) {
      // User wants to proceed, request permissions
      context.read<OnboardingBloc>().add(PermissionsRequested(context));
    }
  }

  /// Request all permissions
  Future<void> _requestPermissions(BuildContext context, AppLocalizations l10n) async {
    final result = await PermissionHelper.requestAllOnboardingPermissions(
      context: context,
      // Photo permission strings
      photoEducationTitle: l10n.permissionPhotoAccessTitle,
      photoEducationMessage: l10n.permissionPhotoAccessMessage,
      photoDeniedTitle: l10n.permissionPhotoAccessDeniedTitle,
      photoDeniedMessage: l10n.permissionPhotoAccessDeniedMessage,
      // Notification permission strings
      notificationEducationTitle: l10n.permissionNotificationTitle,
      notificationEducationMessage: l10n.permissionNotificationMessage,
      notificationDeniedTitle: l10n.permissionNotificationDeniedTitle,
      notificationDeniedMessage: l10n.permissionNotificationDeniedMessage,
      // Background permission strings
      backgroundEducationTitle: l10n.permissionBackgroundTitle,
      backgroundEducationMessageAndroid: l10n.permissionBackgroundMessageAndroid,
      backgroundEducationMessageIOS: l10n.permissionBackgroundMessageIOS,
      backgroundDeniedTitle: l10n.permissionBackgroundDeniedTitle,
      backgroundDeniedMessage: l10n.permissionBackgroundDeniedMessage,
      // Button texts
      continueText: l10n.permissionPhotoAccessContinue,
      settingsText: l10n.permissionOpenSettings,
      cancelText: l10n.cancel,
    );

    if (mounted) {
      // Dispatch the result to the BLoC
      context.read<OnboardingBloc>().add(PermissionsGranted(
            photoGranted: result.photoGranted,
            notificationGranted: result.notificationGranted,
            backgroundGranted: result.backgroundGranted,
          ));
    }
  }

  /// Show rejection warning dialog
  Future<void> _showRejectionWarningDialog(
    BuildContext context,
    AppLocalizations l10n,
    OnboardingPermissionsPartiallyDenied state,
  ) async {
    // Build limitations list
    final limitations = <String>[];
    if (!state.photoGranted) {
      limitations.add(l10n.permissionLimitationPhoto);
    }
    if (!state.notificationGranted) {
      limitations.add(l10n.permissionLimitationNotification);
    }
    if (!state.backgroundGranted) {
      limitations.add(l10n.permissionLimitationBackground);
    }

    // Build the full message with the limitations list
    final limitationsMessage =
        '${l10n.onboardingPermissionsRejectedMessage}\n\n${limitations.join('\n')}';

    // Show warning dialog
    final shouldRetry = await PermissionRejectionWarningDialog.show(
      context: context,
      title: l10n.onboardingPermissionsRejectedTitle,
      message: limitationsMessage,
      retryButtonText: l10n.onboardingPermissionsRetryButton,
      continueButtonText: l10n.onboardingPermissionsRejectedButton,
    );

    if (mounted) {
      if (shouldRetry) {
        // User wants to retry
        context.read<OnboardingBloc>().add(RetryPermissionsRequested(context));
      } else {
        // User understands and wants to continue
        context.read<OnboardingBloc>().add(const OnboardingCompleted());
      }
    }
  }
}
