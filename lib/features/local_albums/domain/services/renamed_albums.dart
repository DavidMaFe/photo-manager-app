import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';

/// Folders renamed on the device (ROADMAP-local-albums.md, Phase 0): renaming a folder gives its album a new id, but
/// its files keep theirs. A new album with files of an album that is gone is that album renamed.
class RenamedAlbums {
  const RenamedAlbums._();

  /// [previous]: the albums of the last registration, with some ids of their files. Answers new id → old id.
  static Map<String, String> find({required Map<String, Set<String>> previous, required List<GalleryAlbum> current}) {
    final currentIds = {for (final album in current) album.id};
    final gone = {
      for (final entry in previous.entries)
        if (!currentIds.contains(entry.key)) entry.key: entry.value,
    };

    // Every pair of a new album and an album that is gone with files in common, the most files first
    final pairs = <(String, String, int)>[];
    for (final album in current) {
      if (previous.containsKey(album.id)) continue;
      for (final entry in gone.entries) {
        final overlap = entry.value.intersection(album.sampleAssetIds).length;
        if (overlap > 0) pairs.add((album.id, entry.key, overlap));
      }
    }
    pairs.sort((a, b) => b.$3.compareTo(a.$3));

    final renamed = <String, String>{};
    final taken = <String>{};
    for (final (newId, oldId, _) in pairs) {
      if (renamed.containsKey(newId) || taken.contains(oldId)) continue;
      renamed[newId] = oldId;
      taken.add(oldId);
    }
    return renamed;
  }
}
