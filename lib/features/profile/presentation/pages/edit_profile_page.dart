import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/basic_info_section.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/password_change_section.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/profile_photo_picker.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String? _selectedProfileImageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Initialize with current profile data
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _nameController.text = state.userProfile.name;
      _surnameController.text = state.userProfile.surname ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileBloc = context.read<ProfileBloc>();
    final currentState = profileBloc.state;

    if (currentState is! ProfileLoaded) {
      return;
    }

    final currentProfile = currentState.userProfile;

    // Check if any profile data changed
    final nameChanged = _nameController.text != currentProfile.name;
    final surnameChanged = _surnameController.text != (currentProfile.surname ?? '');
    final photoChanged = _selectedProfileImageBase64 != null;

    // Check if password is being changed
    final isChangingPassword = _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty;

    if (!nameChanged && !surnameChanged && !photoChanged && !isChangingPassword) {
      // Nothing changed, just go back
      if (mounted) context.pop();
      return;
    }

    // Update profile if basic info or photo changed
    if (nameChanged || surnameChanged || photoChanged) {
      profileBloc.add(UpdateProfileRequested(
        name: nameChanged ? _nameController.text : null,
        surname: surnameChanged ? _surnameController.text : null,
        profileImage: _selectedProfileImageBase64,
      ));
    }

    // Change password if requested
    if (isChangingPassword) {
      profileBloc.add(ChangePasswordRequested(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.palette.surface2,
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
        backgroundColor: context.palette.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdating || state is PasswordChanging) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ProfileUpdateSuccess) {
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.profileUpdatedSuccessfully),
                backgroundColor: context.palette.safe,
              ),
            );

            // If no password change, navigate back
            if (_currentPasswordController.text.isEmpty) {
              context.pop();
            }
          } else if (state is PasswordChangeSuccess) {
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.passwordChangedSuccessfully),
                backgroundColor: context.palette.safe,
              ),
            );

            context.pop();
          } else if (state is ProfileUpdateError) {
            setState(() {
              _isLoading = false;
            });

            ErrorNotificationService.showError(
              context,
              state.failure,
              config: ErrorDisplayConfig.snackBar,
              onRetry: _saveChanges,
            );
          } else if (state is PasswordChangeError) {
            setState(() {
              _isLoading = false;
            });

            ErrorNotificationService.showError(
              context,
              state.failure,
              config: ErrorDisplayConfig.snackBar,
              onRetry: _saveChanges,
            );
          }
        },
        builder: (context, state) {
          final profile = state is ProfileLoaded
              ? state.userProfile
              : (state is ProfileUpdateSuccess
                  ? state.userProfile
                  : null);

          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Photo Picker
                  ProfilePhotoPicker(
                    currentPhotoUrl: profile.profileImageUrl,
                    fullName: profile.fullName,
                    onPhotoSelected: (base64Image) {
                      setState(() {
                        _selectedProfileImageBase64 = base64Image;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Basic Info Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.palette.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.palette.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: BasicInfoSection(
                      nameController: _nameController,
                      surnameController: _surnameController,
                      enabled: !_isLoading,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password Change Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.palette.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.palette.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PasswordChangeSection(
                      currentPasswordController: _currentPasswordController,
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      enabled: !_isLoading,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.palette.accent,
                      foregroundColor: context.palette.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(context.palette.onAccent),
                            ),
                          )
                        : Text(
                            l10n.saveChanges,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
