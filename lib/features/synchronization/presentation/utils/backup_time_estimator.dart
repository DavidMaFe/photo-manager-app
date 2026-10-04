/// Estimates the time left of a running backup from the average time per
/// uploaded file since the upload started.
class BackupTimeEstimator {

  /// Files needed before showing an estimate, so it is not wildly off.
  static const int minimumSamples = 3;

  DateTime? _startedAt;
  int _startCount = 0;

  void reset() {
    _startedAt = null;
    _startCount = 0;
  }

  /// Records a progress update and returns the estimated time left, or
  /// `null` while there is not enough data.
  Duration? update({required int uploaded, required int total, required DateTime now}) {
    if (_startedAt == null) {
      _startedAt = now;
      _startCount = uploaded;
      return null;
    }

    final samples = uploaded - _startCount;
    if (samples < minimumSamples || total <= uploaded) return null;

    final perFile = now.difference(_startedAt!).inMilliseconds / samples;
    return Duration(milliseconds: (perFile * (total - uploaded)).round());
  }
}
