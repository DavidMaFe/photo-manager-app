import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../../../../core/widgets/authenticated_image.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final String? currentPhotoUrl;
  final String fullName;
  final Function(String?) onPhotoSelected;

  const ProfilePhotoPicker({
    super.key,
    this.currentPhotoUrl,
    required this.fullName,
    required this.onPhotoSelected,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  String? _selectedImageBase64;

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.selectProfilePhoto),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImageBase64 = base64Image;
        });

        widget.onPhotoSelected(_selectedImageBase64);
      }
    }
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              _selectedImageFile != null || (widget.currentPhotoUrl != null && widget.currentPhotoUrl!.isNotEmpty)
                  ? SizedBox(
                width: 120,
                height: 120,
                child: ClipOval(
                  child: _selectedImageFile != null
                      ? Image.file(
                    _selectedImageFile!,
                    fit: BoxFit.cover,
                  )
                      : AuthenticatedImage(
                    imageUrl: widget.currentPhotoUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : CircleAvatar(
                radius: 60,
                backgroundColor: PhotoManagerColors.primary,
                child: Text(
                  _getInitials(widget.fullName),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _pickImage,
            child: Text(l10n.changePhoto),
          ),
        ],
      ),
    );
  }
}
