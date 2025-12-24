
class SyncDevice {

  final String id;
  final String uuid;
  final String name;
  final String model;
  final String osType;
  final String osVersion;
  final String appVersion;
  final String userId;

  SyncDevice({
    required this.id,
    required this.uuid,
    required this.name,
    required this.model,
    required this.osType,
    required this.osVersion,
    required this.appVersion,
    required this.userId
  });

  bool get isAndroid => osType.toLowerCase() == 'android';
  bool get isIOS => osType.toLowerCase() == 'ios';

  factory SyncDevice.empty() {
    return SyncDevice(
      id: '',
      uuid: '',
      name: '',
      model: '',
      osType: '',
      osVersion: '',
      appVersion: '',
      userId: '',
    );
  }

  SyncDevice copyWith({
    String? id,
    String? uuid,
    String? name,
    String? model,
    String? osType,
    String? osVersion,
    String? appVersion,
    String? userId
  }) {
    return SyncDevice(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      model: model ?? this.model,
      osType: osType ?? this.osType,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}