import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/core/widgets/section_label.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/basic_info_section.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/password_change_section.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/profile_photo_picker.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {

  /// Opens the page scrolled to the password section.
  final bool scrollToPassword;

  const EditProfilePage({super.key, this.scrollToPassword = false});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordSectionKey = GlobalKey();

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

    if (widget.scrollToPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final sectionContext = _passwordSectionKey.currentContext;
        if (sectionContext != null) {
          Scrollable.ensureVisible(sectionContext, duration: const Duration(milliseconds: 300));
        }
      });
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
      appBar: SecondaryTopBar(title: l10n.editProfileTitle, onBack: () => context.pop()),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        // Keep the form on screen while saving; the button shows the progress.
        buildWhen: (previous, current) => current is ProfileLoaded || current is ProfileUpdateSuccess,
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
              SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
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
              SnackBar(content: Text(l10n.passwordChangedSuccessfully)),
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
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        ProfilePhotoPicker(
                          currentPhotoUrl: profile.profileImageUrl,
                          name: profile.name,
                          surname: profile.surname,
                          onPhotoSelected: (base64Image) {
                            setState(() {
                              _selectedProfileImageBase64 = base64Image;
                            });
                          },
                        ),
                        SectionLabel(l10n.sectionData),
                        AppCard(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: BasicInfoSection(
                            nameController: _nameController,
                            surnameController: _surnameController,
                            enabled: !_isLoading,
                          ),
                        ),
                        SectionLabel(l10n.sectionPassword, key: _passwordSectionKey),
                        AppCard(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: PasswordChangeSection(
                            currentPasswordController: _currentPasswordController,
                            newPasswordController: _newPasswordController,
                            confirmPasswordController: _confirmPasswordController,
                            enabled: !_isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _BottomActionBar(
                child: AppButton.primary(
                  label: l10n.saveChanges,
                  onPressed: _saveChanges,
                  loading: _isLoading,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Primary action anchored at the bottom (background + top line).
class _BottomActionBar extends StatelessWidget {
  final Widget child;

  const _BottomActionBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.background,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: child),
      ),
    );
  }
}
