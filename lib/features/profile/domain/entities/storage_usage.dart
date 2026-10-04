/// Storage used by type. `photosBytes + videosBytes + trashBytes == usedBytes`.
class StorageUsage {

  final int photosBytes;
  final int videosBytes;
  final int trashBytes;
  final int usedBytes;
  final int quotaBytes;

  const StorageUsage({
    required this.photosBytes,
    required this.videosBytes,
    required this.trashBytes,
    required this.usedBytes,
    required this.quotaBytes,
  });

  /// Fraction of the bar for [bytes]: of the quota, or of the use if it goes over it.
  double fractionOf(int bytes) {
    final total = quotaBytes > usedBytes ? quotaBytes : usedBytes;
    return total > 0 ? bytes / total : 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageUsage &&
          other.photosBytes == photosBytes &&
          other.videosBytes == videosBytes &&
          other.trashBytes == trashBytes &&
          other.usedBytes == usedBytes &&
          other.quotaBytes == quotaBytes;

  @override
  int get hashCode => Object.hash(photosBytes, videosBytes, trashBytes, usedBytes, quotaBytes);
}
