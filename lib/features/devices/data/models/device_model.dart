import 'package:photo_manager_app/features/devices/domain/entities/device.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required super.id,
    required super.uuid,
    required super.name,
    required super.model,
    required super.osType,
    required super.osVersion,
    required super.appVersion,
    required super.autoSync,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['deviceId'].toString(),
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      model: json['model'] as String,
      osType: json['osType'] as String,
      osVersion: json['osVersion'] as String,
      appVersion: json['appVersion'] as String,
      autoSync: json['autoSyncEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'model': model,
      'osType': osType,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'autoSync': autoSync,
    };
  }

  factory DeviceModel.fromEntity(Device device) {
    return DeviceModel(
      id: device.id,
      uuid: device.uuid,
      name: device.name,
      model: device.model,
      osType: device.osType,
      osVersion: device.osVersion,
      appVersion: device.appVersion,
      autoSync: device.autoSync,
    );
  }
}
