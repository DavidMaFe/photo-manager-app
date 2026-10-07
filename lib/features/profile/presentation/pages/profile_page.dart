import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
import 'package:photo_manager_app/core/widgets/section_label.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/security_section.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/dialogs/logout_confirmation_dialog.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_stats.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/storage_bar.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/sync_config_summary.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/theme_mode_sheet.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';


class ProfilePage extends StatefulWidget {

  /// Extra passed to the edit profile route to open it on the password section.
  static const String passwordSection = 'password';

  /// Where the theme is saved (injectable for tests).
  final UiPreferencesService? uiPreferences;

  const ProfilePage({super.key, this.uiPreferences});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _syncConfigKey = GlobalKey<SyncConfigLoaderState>();

  UiPreferencesService get _uiPreferences => widget.uiPreferences ?? sl<UiPreferencesService>();

  Future<void> _chooseTheme(BuildContext context, ThemeMode current) async {
    final mode = await ThemeModeSheet.show(context, selected: current);
    if (mode != null && mode != current) await _uiPreferences.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ErrorNotificationService.showError(
                context,
                state.failure,
                config: ErrorDisplayConfig.snackBar,
                onRetry: () {
                  context.read<ProfileBloc>().add(LoadProfileRequested());
                },
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return _buildContent(context, state, l10n);
            }

            return Column(
              children: [
                ScreenHeader(title: l10n.navProfile),
                Expanded(
                  child: state is ProfileError
                      ? ErrorDisplay(
                          failure: state.failure,
                          onRetry: () => context.read<ProfileBloc>().add(LoadProfileRequested()),
                        )
                      : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileLoaded state, AppLocalizations l10n) {

    final profile = state.userProfile;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(RefreshProfileRequested());
        _syncConfigKey.currentState?.reload();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          ScreenHeader(title: l10n.navProfile),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ProfileHeader(
              profile: profile,
              onEdit: () => context.goNamed(RouteNames.editProfile),
            ),
          ),
          AppCard(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StorageBar(profile: profile),
                const SizedBox(height: 18),
                ProfileStats(profile: profile),
              ],
            ),
          ),
          SyncConfigLoader(
            key: _syncConfigKey,
            builder: (context, config, loading) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(l10n.sectionBackupSpace),
                ListRowGroup(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ListRow(
                      icon: Symbols.cloud_sync_rounded,
                      title: l10n.backupSettings,
                      subtitle: loading ? l10n.loadingConfiguration : SyncConfigSummary.schedule(config, l10n),
                      onTap: () => _openSyncSettings(context),
                    ),
                    ListRow(
                      icon: Symbols.devices_rounded,
                      title: l10n.myDevices,
                      subtitle: l10n.linkedDevices(profile.deviceCount),
                      onTap: () => context.goNamed(RouteNames.devices),
                    ),
                    ListRow(
                      icon: Symbols.delete_rounded,
                      title: l10n.trash,
                      subtitle: l10n.trashAutoEmpty,
                      onTap: () => context.goNamed(RouteNames.trash),
                    ),
                  ],
                ),
                SectionLabel(l10n.sectionApp),
                ListRowGroup(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ListRow(
                      icon: Symbols.notifications_rounded,
                      title: l10n.notifications,
                      value: loading ? null : SyncConfigSummary.notifications(config, l10n),
                      onTap: () => _openSyncSettings(context),
                    ),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: _uiPreferences.themeMode,
                      builder: (context, mode, _) => ListRow(
                        icon: Symbols.contrast_rounded,
                        title: l10n.appearance,
                        value: ThemeModeSheet.labelOf(mode, l10n),
                        onTap: () => _chooseTheme(context, mode),
                      ),
                    ),
                    ListRow(
                      icon: Symbols.password_rounded,
                      title: l10n.passwordLabel,
                      onTap: () => context.goNamed(RouteNames.editProfile, extra: ProfilePage.passwordSection),
                    ),
                  ],
                ),
                SecuritySection(email: profile.email),
                ListRowGroup(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  children: [
                    ListRow(
                      key: const ValueKey('profile-legal-info'),
                      icon: Symbols.info_rounded,
                      title: l10n.legalInfoTitle,
                      onTap: () => context.push(RoutePaths.legal),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: AppButton.danger(
              label: l10n.logoutButton,
              icon: Symbols.logout_rounded,
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSyncSettings(BuildContext context) async {
    await context.pushNamed(RouteNames.syncConfiguration);
    _syncConfigKey.currentState?.reload();
  }

  void _showLogoutDialog(BuildContext context) {
    LogoutConfirmationDialog.show(
      context: context,
      onConfirm: () {
        context.read<AuthBloc>().add(LogoutRequested());
      },
    );
  }
}
