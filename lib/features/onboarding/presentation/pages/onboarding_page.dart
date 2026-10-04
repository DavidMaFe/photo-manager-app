import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/onboarding_notifier.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_access.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:photo_manager_app/features/onboarding/presentation/widgets/permission_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// First launch: one screen to grant photos, notifications and background
/// permissions, each with its own button.
class OnboardingPage extends StatefulWidget {

  /// Called once the onboarding is done (injectable for tests).
  final void Function(BuildContext context)? onFinished;

  const OnboardingPage({super.key, this.onFinished});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>().add(const OnboardingStarted());
    // Back from the system settings: show what changed there.
    _lifecycleListener = AppLifecycleListener(
      onResume: () => context.read<OnboardingBloc>().add(const PermissionsRechecked()),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingComplete) _finish(context);
        },
        builder: (context, state) {
          if (state is! OnboardingPermissions) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          return SafeArea(child: _PermissionsContent(state: state, onContinue: () => _continue(context, state)));
        },
      ),
    );
  }

  void _finish(BuildContext context) {
    if (widget.onFinished != null) {
      widget.onFinished!(context);
      return;
    }
    sl<OnboardingNotifier>().markOnboardingComplete();
    context.go(RoutePaths.home);
  }

  /// Without photos the app cannot back up anything: say so before going on.
  Future<void> _continue(BuildContext context, OnboardingPermissions state) async {
    final bloc = context.read<OnboardingBloc>();
    if (state.photos == PermissionAccess.granted) {
      bloc.add(const OnboardingCompleted());
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final limitations = [
      if (state.photos != PermissionAccess.granted) l10n.permissionLimitationPhoto,
      if (state.notifications != PermissionAccess.granted) l10n.permissionLimitationNotification,
      if (state.background != PermissionAccess.granted) l10n.permissionLimitationBackground,
    ];

    final confirmed = await AppDialog.show(
      context: context,
      icon: Symbols.photo_library_rounded,
      tone: AppDialogTone.review,
      title: l10n.onboardingPermissionsRejectedTitle,
      message: '${l10n.onboardingPermissionsRejectedMessage}\n\n${limitations.join('\n')}',
      primaryLabel: l10n.continueAnyway,
      secondaryLabel: l10n.reviewPermissions,
    );
    if (confirmed == true) bloc.add(const OnboardingCompleted());
  }
}

class _PermissionsContent extends StatelessWidget {
  final OnboardingPermissions state;
  final VoidCallback onContinue;

  const _PermissionsContent({required this.state, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final bloc = context.read<OnboardingBloc>();

    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthSuccessful ? authState.user.name.trim() : '';

    PermissionCard card(AppPermission permission, IconData icon, String title, String body, OnboardingEvent request) {
      return PermissionCard(
        icon: icon,
        title: title,
        description: body,
        access: state.accessOf(permission),
        recommended: state.nextRecommended == permission,
        loading: state.requesting == permission,
        onAllow: () => bloc.add(request),
        onOpenSettings: () => bloc.add(const PermissionSettingsRequested()),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            children: [
              Text(
                name.isEmpty ? l10n.welcomeGeneric : l10n.welcomeUser(name),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.accent),
              ),
              const SizedBox(height: 8),
              Semantics(
                header: true,
                child: Text(l10n.permissionsHeadline, style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.permissionsBody,
                style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w500, color: p.ink2),
              ),
              const SizedBox(height: 24),
              card(AppPermission.photos, Symbols.photo_library_rounded, l10n.permPhotosTitle, l10n.permPhotosBody,
                  const PhotoPermissionRequested()),
              const SizedBox(height: 12),
              card(AppPermission.notifications, Symbols.notifications_rounded, l10n.permNotifTitle, l10n.permNotifBody,
                  const NotificationPermissionRequested()),
              const SizedBox(height: 12),
              card(AppPermission.background, Symbols.cloud_sync_rounded, l10n.permBgTitle, l10n.permBgBody,
                  const BackgroundPermissionRequested()),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Symbols.lock_rounded, size: 18, color: p.ink3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.privacyNote, style: TextStyle(fontSize: 13, height: 1.4, color: p.ink2)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton.primary(label: l10n.continueLabel, onPressed: onContinue),
              const SizedBox(height: 4),
              AppButton.text(label: l10n.later, onPressed: () => bloc.add(const OnboardingCompleted())),
            ],
          ),
        ),
      ],
    );
  }
}
