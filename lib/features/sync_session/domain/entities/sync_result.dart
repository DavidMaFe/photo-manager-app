
class SyncResult {

  final int totalFiles;
  final int uploadedFiles;
  final int failedFiles;

  SyncResult({
    required this.totalFiles,
    required this.uploadedFiles,
    required this.failedFiles,
  });

  bool get isSuccess => failedFiles == 0 && uploadedFiles > 0;
  bool get hasFailures => failedFiles > 0;
  bool get isEmpty => uploadedFiles == 0;

  double get successRate {
    if (totalFiles == 0) return 0.0;
    return (uploadedFiles / totalFiles) * 100;
  }

  factory SyncResult.empty(String sessionId) {
    return SyncResult(
      totalFiles: 0,
      uploadedFiles: 0,
      failedFiles: 0,
    );
  }
}