/// What the backups do with the files of an album of the gallery (ROADMAP-local-albums.md).
enum LocalAlbumMode {
  /// Backed up into the album of Photo Manager with the name of the album, created or joined.
  album('ALBUM'),

  /// Backed up without an album.
  backupOnly('BACKUP_ONLY'),

  /// Not backed up.
  excluded('EXCLUDED');

  /// The value of the API.
  final String code;

  const LocalAlbumMode(this.code);

  static LocalAlbumMode fromCode(String code) =>
      values.firstWhere((mode) => mode.code == code, orElse: () => throw FormatException('Unknown mode $code'));
}
