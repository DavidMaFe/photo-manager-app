

enum SynchronizationStatus {

  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  failed('FAILED'),
  cancelled('CANCELLED');

  final String value;
  const SynchronizationStatus(this.value);

  static SynchronizationStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return SynchronizationStatus.inProgress;
      case 'COMPLETED':
        return SynchronizationStatus.completed;
      case 'FAILED':
        return SynchronizationStatus.failed;
      case 'CANCELLED':
        return SynchronizationStatus.cancelled;
      default:
        throw ArgumentError('Unknown state: $value');
    }
  }
}