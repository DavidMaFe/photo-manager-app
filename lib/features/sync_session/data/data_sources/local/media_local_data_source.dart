import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_file_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/gallery_scan.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/gallery_media_source.dart';


class MediaLocalDataSource implements GalleryMediaSource {

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

  static const int _pageSize = 100;
  static const int _albumPageSize = 500;

  /// [checkPermission] is false in a WorkManager background isolate. There is no foreground Activity there, so
  /// asking for the permission would crash inside Android's ActivityResultLauncher; the permission granted to the app
  /// is still valid in the background.
  @override
  Future<GalleryScan> addedSince(DateTime? since, {bool checkPermission = true}) async {
    if (checkPermission) {
      await _ensureAccess();
    }

    // createTimeCond filters by the date the file arrived on the device (DATE_ADDED on Android), not by its capture
    // date (ROADMAP-local-albums.md, Phase 0)
    final filter = since == null
        ? null
        : FilterOptionGroup(
            createTimeCond: DateTimeCond(min: since, max: DateTime.now().add(const Duration(days: 1))));
    final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common, hasAll: true, onlyAll: true, filterOption: filter);
    if (albums.isEmpty) return GalleryScan.empty;

    final mainAlbum = albums.first;
    final totalAssets = await mainAlbum.assetCountAsync;
    final files = <SyncFileModel>[];
    final unreadable = <String>{};

    for (var page = 0; page * _pageSize < totalAssets; page++) {
      final assets = await mainAlbum.getAssetListPaged(page: page, size: _pageSize);
      if (assets.isEmpty) break;
      for (final asset in assets) {
        final file = await _convertAssetToSyncFileModel(asset);
        if (file == null) {
          unreadable.add(asset.id);
        } else {
          files.add(file);
        }
      }
      if (assets.length < _pageSize) break;
    }

    return GalleryScan(files: files, unreadableIds: unreadable);
  }

  @override
  Future<GalleryScan> withIds(Set<String> localIds) async {
    final files = <SyncFileModel>[];
    final unreadable = <String>{};
    final missing = <String>{};
    for (final id in localIds) {
      final asset = await AssetEntity.fromId(id);
      if (asset == null) {
        missing.add(id);
        continue;
      }
      final file = await _convertAssetToSyncFileModel(asset);
      if (file == null) {
        unreadable.add(id);
      } else {
        files.add(file);
      }
    }
    return GalleryScan(files: files, unreadableIds: unreadable, missingIds: missing);
  }

  /// Reads every album of the gallery page by page (about 3 s for 10 000 files on the S23,
  /// ROADMAP-local-albums.md, Phase 0) and stops when every file asked for has its album.
  @override
  Future<Map<String, String>> albumsOf(Set<String> localIds) async {
    final result = <String, String>{};
    if (localIds.isEmpty) return result;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.common, hasAll: false);
    for (final album in albums) {
      final count = await album.assetCountAsync;
      for (var page = 0; page * _albumPageSize < count; page++) {
        final assets = await album.getAssetListPaged(page: page, size: _albumPageSize);
        for (final asset in assets) {
          if (localIds.contains(asset.id)) {
            result[asset.id] = album.id;
          }
        }
        if (result.length == localIds.length) return result;
      }
    }
    return result;
  }

  Future<void> _ensureAccess() async {
    final permissionState = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
        androidPermission: AndroidPermission(type: RequestType.common, mediaLocation: false),
      ),
    );
    if (!permissionState.isAuth && permissionState != PermissionState.limited) {
      throw Exception('No permission to access the gallery');
    }
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