/// Metadata that only the devices of the user can read (docs/e2ee-spec.md, section 7.1).
class FileMetadata {
  final String? name;
  final String? mimeType;

  const FileMetadata({this.name, this.mimeType});

  factory FileMetadata.fromDecrypted(Map<String, Object?> json) =>
      FileMetadata(name: json['name'] as String?, mimeType: json['mime'] as String?);
}
