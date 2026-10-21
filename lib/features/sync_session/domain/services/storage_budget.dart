import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';

/// The free space of the plan during a backup: what the server will still accept. A file is checked against it
/// before it is sent, so a file that does not fit never leaves the device (ROADMAP-sync-quota.md).
///
/// Without a plan (it could not be read) nothing is limited: the server decides.
class StorageBudget {
  int? _remainingBytes;

  StorageBudget(UserPlan? plan) {
    refresh(plan);
  }

  /// No limit: the plan is unknown.
  StorageBudget.unlimited() : _remainingBytes = null;

  /// Free bytes, or null without a limit.
  int? get remainingBytes => _remainingBytes;

  bool fits(int bytes) {
    final remaining = _remainingBytes;
    return remaining == null || bytes <= remaining;
  }

  /// A file was stored: its bytes are no longer free.
  void spend(int bytes) {
    final remaining = _remainingBytes;
    if (remaining != null) {
      _remainingBytes = remaining - bytes < 0 ? 0 : remaining - bytes;
    }
  }

  /// The space as the server sees it now (after it rejected a file, or another device uploaded meanwhile).
  void refresh(UserPlan? plan) {
    if (plan == null) {
      _remainingBytes = null;
      return;
    }
    final free = plan.limits.storageBytes - plan.storedBytes;
    _remainingBytes = free < 0 ? 0 : free;
  }
}

/// A file that does not fit in the free space of the plan: it was not sent. [storedBytes] is what it would take on
/// the server (the encrypted file, its thumbnail and its 2048 px version).
class FileDoesNotFitFailure extends StorageSpaceExceededFailure {
  final int storedBytes;

  const FileDoesNotFitFailure(this.storedBytes) : super(code: 'FILE_DOES_NOT_FIT');
}
