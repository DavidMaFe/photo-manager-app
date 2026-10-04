class Device {
  final String id;
  final String uuid;
  final String name;
  final String model;
  final String osType;
  final String osVersion;
  final String appVersion;
  final bool autoSync;

  /// End of the last completed backup from this device; `null` if it never backed up.
  final DateTime? lastSyncAt;

  const Device({
    required this.id,
    required this.uuid,
    required this.name,
    required this.model,
    required this.osType,
    required this.osVersion,
    required this.appVersion,
    required this.autoSync,
    this.lastSyncAt,
  });

  bool get isAndroid => osType.toLowerCase() == 'android';

  bool get isIOS => osType.toLowerCase() == 'ios';

  Device copyWith({
    String? id,
    String? uuid,
    String? name,
    String? model,
    String? osType,
    String? osVersion,
    String? appVersion,
    bool? autoSync,
    DateTime? lastSyncAt,
  }) {
    return Device(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      model: model ?? this.model,
      osType: osType ?? this.osType,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      autoSync: autoSync ?? this.autoSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Device{id: $id, name: $name, osType: $osType, osVersion: $osVersion, autoSync: $autoSync}';
  }
}
