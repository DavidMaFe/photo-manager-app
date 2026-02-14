enum NetworkPreference {
  wifiOnly,
  anyNetwork;

  String toJson() => name;

  static NetworkPreference fromJson(String json) {
    return NetworkPreference.values.firstWhere(
      (e) => e.name == json,
      orElse: () => NetworkPreference.wifiOnly,
    );
  }

  bool get isWifiOnly => this == NetworkPreference.wifiOnly;
  bool get isAnyNetwork => this == NetworkPreference.anyNetwork;
}
