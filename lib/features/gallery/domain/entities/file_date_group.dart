import 'gallery_file.dart';

class FileDateGroup {
  final DateTime date;
  final String label;
  final List<GalleryFile> files;

  const FileDateGroup({
    required this.date,
    required this.label,
    required this.files,
  });

  FileDateGroup copyWith({
    DateTime? date,
    String? label,
    List<GalleryFile>? files,
  }) {
    return FileDateGroup(
      date: date ?? this.date,
      label: label ?? this.label,
      files: files ?? this.files,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDateGroup &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          label == other.label &&
          files == other.files;

  @override
  int get hashCode => date.hashCode ^ label.hashCode ^ files.hashCode;

  @override
  String toString() =>
      'FileDateGroup(date: $date, label: $label, filesCount: ${files.length})';
}
