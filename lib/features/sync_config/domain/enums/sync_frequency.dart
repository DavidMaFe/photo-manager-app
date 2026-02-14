enum SyncFrequency {
  daily,
  weekly;

  String toJson() => name;

  static SyncFrequency fromJson(String json) {
    return SyncFrequency.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SyncFrequency.daily,
    );
  }

  bool get isDaily => this == SyncFrequency.daily;
  bool get isWeekly => this == SyncFrequency.weekly;
}
