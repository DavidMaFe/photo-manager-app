import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/core/widgets/user_avatar.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// User row: avatar, name, email and an "Edit" button.
class ProfileHeader extends StatelessWidget {

  final UserProfile profile;
  final VoidCallback? onEdit;

  const ProfileHeader({super.key, required this.profile, this.onEdit});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Row(
      children: [
        UserAvatar(
          name: profile.name,
          surname: profile.surname,
          size: 64,
          photo: profile.hasProfileImage
              ? AuthenticatedImage(imageUrl: profile.profileImageUrl!, fit: BoxFit.cover)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.ink),
              ),
              const SizedBox(height: 2),
              Text(
                profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ],
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 8),
          AppButton.neutral(label: l10n.edit, size: AppButtonSize.small, onPressed: onEdit),
        ],
      ],
    );
  }
}
