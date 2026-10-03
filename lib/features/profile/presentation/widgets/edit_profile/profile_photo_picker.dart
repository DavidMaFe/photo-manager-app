import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/core/widgets/user_avatar.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// 96 px avatar with a camera button and "Change photo".
class ProfilePhotoPicker extends StatefulWidget {
  final String? currentPhotoUrl;
  final String name;
  final String? surname;
  final Function(String?) onPhotoSelected;

  /// Injectable for tests.
  final ImagePicker? picker;

  const ProfilePhotoPicker({
    super.key,
    this.currentPhotoUrl,
    required this.name,
    this.surname,
    required this.onPhotoSelected,
    this.picker,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  File? _selectedImageFile;

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    final source = await showAppSheet<ImageSource>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.selectProfilePhoto, style: Theme.of(sheetContext).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListRowGroup(
            children: [
              ListRow(
                icon: Symbols.photo_library_rounded,
                title: l10n.gallerySource,
                showChevron: false,
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              ListRow(
                icon: Symbols.photo_camera_rounded,
                title: l10n.camera,
                showChevron: false,
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
            ],
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final bytes = await File(pickedFile.path).readAsBytes();
    setState(() => _selectedImageFile = File(pickedFile.path));
    widget.onPhotoSelected(base64Encode(bytes));
  }

  Widget? _photo() {
    if (_selectedImageFile != null) {
      return Image.file(_selectedImageFile!, fit: BoxFit.cover);
    }
    final url = widget.currentPhotoUrl;
    if (url != null && url.isNotEmpty) {
      return AuthenticatedImage(imageUrl: url, fit: BoxFit.cover);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(name: widget.name, surname: widget.surname, size: 96, photo: _photo()),
            Positioned(
              right: -4,
              bottom: -4,
              child: Tooltip(
                message: l10n.changePhoto,
                child: Material(
                  color: p.surface,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: p.shadow,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _pickImage,
                    child: SizedBox.square(
                      dimension: 36,
                      child: Icon(Symbols.photo_camera_rounded, size: 20, color: p.ink),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _pickImage, child: Text(l10n.changePhoto)),
      ],
    );
  }
}
