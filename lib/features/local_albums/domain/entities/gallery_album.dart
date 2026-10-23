/// An album of the gallery of the device: a folder with photos or videos (the bucket of MediaStore on Android).
class GalleryAlbum {
  /// Comes from the path of the folder: a folder renamed on the device gets a new one.
  final String id;
  final String name;

  /// The folder, e.g. `DCIM/Camera/`; null where the system does not say it (iOS).
  final String? relativePath;
  final int assetCount;

  /// Some ids of its files, to recognize the album when its folder is renamed.
  final Set<String> sampleAssetIds;

  const GalleryAlbum({
    required this.id,
    required this.name,
    this.relativePath,
    required this.assetCount,
    this.sampleAssetIds = const {},
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is GalleryAlbum && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
