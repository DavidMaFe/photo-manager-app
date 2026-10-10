import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_file_model.dart';


class MediaLocalDataSource {

  MediaLocalDataSource();

  Future<PermissionState> checkPermission({
    bool requestIfDenied = false,
  }) async {
    if (requestIfDenied) {
      return await PhotoManager.requestPermissionExtend();
    }

    return await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
        androidPermission: AndroidPermission(
          type: RequestType.common,
          mediaLocation: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
        androidPermission: AndroidPermission(
          type: RequestType.common,
          mediaLocation: false
        )
      )
    );

    return state.isAuth || state == PermissionState.limited;
  }

  /// Scan device media files and return them as [SyncFileModel] instances.
  ///
  /// [skipPermissionCheck] should be set to `true` when called from a
  /// WorkManager background isolate. In that context there is no foreground
  /// Activity, so calling [PhotoManager.requestPermissionExtend] would crash
  /// with a NullPointerException inside Android's ActivityResultLauncher.
  /// The OS-level media permission is already granted by the main app process
  /// and remains valid in background — we just cannot show the dialog again.
  Future<List<SyncFileModel>> scanMediaFiles({
    DateTime? lastCompletedSyncAt,
    bool skipPermissionCheck = false,
  }) async {
    if (!skipPermissionCheck) {
      final permissionState = await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(
          iosAccessLevel: IosAccessLevel.readWrite,
          androidPermission: AndroidPermission(
            type: RequestType.common,
            mediaLocation: false,
          ),
        ),
      );

      if (!permissionState.isAuth &&
          permissionState != PermissionState.limited) {
        throw Exception('No permission to access the gallery');
      }
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type:  RequestType.common, hasAll: true, onlyAll: true
    );

    // There is no main album
    if (albums.isEmpty) return [];

    final mainAlbum = albums.first;
    final int totalAssets = await mainAlbum.assetCountAsync;

    final List<SyncFileModel> scannedFiles = [];

    const int pageSize = 100;
    int page = 0;
    bool hasMorePages = true;

    while(hasMorePages) {
      final List<AssetEntity> assets = await mainAlbum.getAssetListPaged(page: page, size: pageSize);
      if (assets.isEmpty) {
        hasMorePages = false;
        break;
      }

      for (final asset in assets) {
        try {

          if (lastCompletedSyncAt != null) {
            final capturedAt = asset.createDateTime;

            if (capturedAt.isBefore(lastCompletedSyncAt) ||
                capturedAt.isAtSameMomentAs(lastCompletedSyncAt)) {
              continue;
            }
          }

          final fileModel = await _convertAssetToSyncFileModel(asset);

          if(fileModel != null) {
            scannedFiles.add(fileModel);
          }

        } catch (ignore) {
          // Ignore the error and continue to the next file
          continue;
        }
      }

      page++;
      if (assets.length < pageSize || (page * pageSize) >= totalAssets) {
        hasMorePages = false;
      }
    }

    return scannedFiles;
  }

  Future<SyncFileModel?> _convertAssetToSyncFileModel(AssetEntity asset) async {
    try {

      final File? file = await asset.file;
      if(file == null || !await file.exists()) return null;

      final String hash = await contentHash(file);

      final String path = file.path;
      final String fileName = path.split('/').last;
      final int sizeBytes = await file.length();
      final DateTime capturedAt = asset.createDateTime;

      String mimeType;
      if(asset.type == AssetType.image) {
        mimeType = _getMimeTypeFromExtension(fileName, 'image');
      } else if (asset.type == AssetType.video) {
        mimeType = _getMimeTypeFromExtension(fileName, 'video');
      } else {
        return null;
      }

      int? width = asset.width;
      int? height = asset.height;
      int? durationSeconds = asset.type == AssetType.video ? asset.duration : null;

      return SyncFileModel(
        localId: asset.id,
        devicePath: path,
        hash: hash,
        fileName: fileName,
        sizeBytes: sizeBytes,
        capturedAt: capturedAt,
        mimeType: mimeType,
        width: width,
        height: height,
        durationSeconds: durationSeconds
      );
    } catch(ignore) {
      return null;
    }
  }

  /// SHA-256 of the content, read in chunks: a 100 MB video is never loaded in memory (docs/e2ee-spec.md, 11).
  /// It stays on the device; the server receives a keyed hash of it.
  static Future<String> contentHash(File file) async {
    try {
      final digest = await sha256.bind(file.openRead()).first;
      return digest.toString();
    } catch(e) {
      throw Exception("Error calculating file hash");
    }
  }

  String _getMimeTypeFromExtension(String fileName, String baseType) {
    final extension = fileName.split('.').last.toLowerCase();

    if(baseType == 'image') {
      switch(extension) {
        case 'jpg':
        case 'jpeg':
          return 'image/jpeg';
        case 'png':
          return 'image/png';
        case 'gif':
          return 'image/gif';
        case 'heic':
        case 'heif':
          return 'image/heic';
        case 'webp':
          return 'image/webp';
        default:
          return 'image/jpeg';
      }
    }

    if(baseType == 'video') {
      switch (extension) {
        case 'mp4':
          return 'video/mp4';
        case 'mov':
          return 'video/quicktime';
        case 'avi':
          return 'video/x-msvideo';
        case 'mkv':
          return 'video/x-matroska';
        case '3gp':
          return 'video/3gpp';
        default:
          return 'video/mp4';
      }
    }

    return 'application/octet-stream';
  }
}