import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
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
              backgroundColor: context.palette.accent,
              child: Text(
                  _getInitials(profile.fullName),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.palette.onAccent)
              ),
            ),
          ],
        ),

        Text(
          profile.fullName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.palette.ink
          )
        ),

        const SizedBox(height: 4),

        InkWell(
          onTap: () {},
          child: Text(
            profile.email,
            style: TextStyle(
              fontSize: 14,
              color: context.palette.accentInk,
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