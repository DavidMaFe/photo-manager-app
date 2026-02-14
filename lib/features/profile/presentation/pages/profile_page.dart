
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/dialogs/logout_confirmation_dialog.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_stats.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/storage_bar.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/sync_settings_menu_item.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';


class ProfilePage extends StatelessWidget {

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
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
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator()
              );
            }

            if (state is ProfileLoaded) {
              final profile = state.userProfile;
        
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(RefreshProfileRequested());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ProfileHeader(profile: profile),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2)
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StorageBar(profile: profile),
                            const SizedBox(height: 24),
                            ProfileStats(profile: profile)
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2)
                            )
                          ]
                        ),
                        child: Column(
                          children: [
                            ProfileMenuItem(
                              icon: Icons.person_outline,
                              title: l10n.editProfile,
                              subtitle: l10n.editProfileSubtitle,
                              onTap: () {
                                context.goNamed(RouteNames.editProfile);
                              },
                            ),
                            const Divider(height: 1, indent: 60),
        
                            ProfileMenuItem(
                              icon: Icons.devices_outlined,
                              title: l10n.myDevices,
                              subtitle: l10n.myDevicesSubtitle(profile.deviceCount),
                              onTap: () {
                                context.goNamed(RouteNames.devices);
                              },
                            ),
                            const Divider(height: 1, indent: 60),

                            ProfileMenuItem(
                              icon: Icons.delete_outline,
                              title: l10n.trash,
                              subtitle: l10n.trashSubtitle,
                              onTap: () {
                                context.goNamed(RouteNames.trash);
                              },
                            ),
                            const Divider(height: 1, indent: 60),

                            const SyncSettingsMenuItem(),
                            const Divider(height: 1, indent: 60),
        
                            ProfileMenuItem(
                              icon: Icons.notifications_outlined,
                              title: l10n.notifications,
                              subtitle: l10n.notificationsSubtitle,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showLogoutDialog(context, l10n);
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: Text(
                            l10n.logoutButton,
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12)
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 40)
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    LogoutConfirmationDialog.show(
      context: context,
      onConfirm: () {
        context.read<AuthBloc>().add(LogoutRequested());
      },
    );
  }
}