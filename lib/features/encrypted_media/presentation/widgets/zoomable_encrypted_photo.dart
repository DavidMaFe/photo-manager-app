import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_photo_viewer.dart';

/// A photo of the viewer that can be zoomed up to 4×. A file with a 2048 px version opens with it, and the original
/// is downloaded only when the zoom goes past [originalZoomThreshold], where the 2048 px version starts to lose
/// detail on a phone screen. Once loaded, the original stays while the photo is open.
class ZoomableEncryptedPhoto extends StatefulWidget {
  static const double originalZoomThreshold = 1.5;

  final String fileId;
  final bool hasPreview;
  final LoadMediaUseCase? loadMedia;

  const ZoomableEncryptedPhoto({super.key, required this.fileId, this.hasPreview = false, this.loadMedia});

  @override
  State<ZoomableEncryptedPhoto> createState() => _ZoomableEncryptedPhotoState();
}

class _ZoomableEncryptedPhotoState extends State<ZoomableEncryptedPhoto> {
  final TransformationController _transformation = TransformationController();
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    _transformation.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformation
      ..removeListener(_onTransformationChanged)
      ..dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    if (!widget.hasPreview || _showOriginal) {
      return;
    }
    if (_transformation.value.getMaxScaleOnAxis() > ZoomableEncryptedPhoto.originalZoomThreshold) {
      setState(() => _showOriginal = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformation,
      minScale: 1,
      maxScale: 4.0,
      child: Center(
        child: EncryptedPhotoViewer(
          fileId: widget.fileId,
          hasPreview: widget.hasPreview,
          showOriginal: _showOriginal,
          loadMedia: widget.loadMedia,
        ),
      ),
    );
  }
}
