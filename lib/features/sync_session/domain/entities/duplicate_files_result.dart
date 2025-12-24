
class DuplicateFilesResult {

  final List<String> filesToUpload;
  final int duplicatesCount;
  final int totalFiles;

  DuplicateFilesResult({
    required this.filesToUpload,
    required this.duplicatesCount,
    required this.totalFiles
  });

  bool get hasFilesToUpload => filesToUpload.isNotEmpty;
  bool get allFilesAreDuplicates => filesToUpload.isEmpty && duplicatesCount > 0;

  factory DuplicateFilesResult.empty() {
    return DuplicateFilesResult(
      filesToUpload: [],
      duplicatesCount: 0,
      totalFiles: 0
    );
  }
}