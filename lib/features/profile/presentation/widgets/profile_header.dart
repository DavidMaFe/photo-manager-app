import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

import '../../../../core/widgets/authenticated_image.dart';


class ProfileHeader extends StatelessWidget {

  final UserProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            profile.hasProfileImage
                ? SizedBox(
              width: 100,
              height: 100,
              child: ClipOval(
                child: AuthenticatedImage(
                  imageUrl: profile.profileImageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            )
                : CircleAvatar(
              radius: 50,
              backgroundColor: PhotoManagerColors.primary,
              child: Text(
                  _getInitials(profile.fullName),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
          ],
        ),

        Text(
          profile.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87
          )
        ),

        const SizedBox(height: 4),

        InkWell(
          onTap: () {},
          child: Text(
            profile.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
          ),
        )
      ],
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if(parts.isEmpty) return '?';
    if(parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}