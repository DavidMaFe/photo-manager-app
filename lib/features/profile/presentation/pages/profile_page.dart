

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_stats.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/storage_bar.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';


class ProfilePage extends StatelessWidget {

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator()
              );
            }
            
            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading the profile', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ProfileBloc>().add(LoadProfileRequested());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again')
                    )
                  ],
                )
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
                              title: 'Edit Profile',
                              subtitle: 'Change name and surname',
                              onTap: () {},
                            ),
                            const Divider(height: 1, indent: 60),
        
                            ProfileMenuItem(
                              icon: Icons.devices_outlined,
                              title: 'My Devices',
                              subtitle: '${profile.deviceCount} linked devices',
                              onTap: () {},
                            ),
                            const Divider(height: 1, indent: 60),
        
                            ProfileMenuItem(
                              icon: Icons.sync_outlined,
                              title: 'Sync Settings',
                              subtitle: 'Auto sync every 6 hours',
                              onTap: () {},
                            ),
                            const Divider(height: 1, indent: 60),
        
                            ProfileMenuItem(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              subtitle: 'Manage notifications',
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
                            _showLogoutDialog(context);
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Logout',
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
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout')
          )
        ]
      )
    );
  }
}