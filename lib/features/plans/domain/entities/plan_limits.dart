import 'package:equatable/equatable.dart';

/// What a plan allows.
class PlanLimits extends Equatable {
  /// Stored bytes (the original, its thumbnail and its 2048 px version count).
  final int storageBytes;
  final int maxDevices;

  /// Plaintext size of a video.
  final int maxVideoBytes;

  /// The automatic backup can run every day; otherwise only weekly.
  final bool dailyBackup;

  const PlanLimits({
    required this.storageBytes,
    required this.maxDevices,
    required this.maxVideoBytes,
    required this.dailyBackup,
  });

  @override
  List<Object?> get props => [storageBytes, maxDevices, maxVideoBytes, dailyBackup];
}
