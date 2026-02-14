enum BatteryPreference {
  any,
  chargingOrAbove15Percent;

  String toJson() => name;

  static BatteryPreference fromJson(String json) {
    return BatteryPreference.values.firstWhere(
      (e) => e.name == json,
      orElse: () => BatteryPreference.any,
    );
  }

  bool get isAny => this == BatteryPreference.any;
  bool get isChargingOrAbove15Percent => this == BatteryPreference.chargingOrAbove15Percent;
}
