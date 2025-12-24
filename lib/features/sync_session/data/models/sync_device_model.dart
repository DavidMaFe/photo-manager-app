import 'package:photo_manager_app/features/sync_session/domain/entities/sync_device.dart';


class SyncDeviceModel extends SyncDevice {

  SyncDeviceModel({
    required super.id,
    required super.uuid,
    required super.name,
    required super.model,
    required super.osType,
    required super.osVersion,
    required super.appVersion,
    required super.userId,
  });

  static String parseDeviceIdFromJson(Map<String, dynamic> json) {
    return json['deviceId'].toString();
  }

  factory SyncDeviceModel.fromRegistrationResponse({
    required String id,
    required String uuid,
    required String name,
    required String model,
    required String osType,
    required String osVersion,
    required String appVersion,
    required String userId
  }) {
    return SyncDeviceModel(
      id: id, uuid: uuid, name: name, model: model, osType: osType,
        osVersion: osVersion, appVersion: appVersion, userId: userId
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
      'userId': userId
    };
  }

  factory SyncDeviceModel.fromJson(Map<String, dynamic> json) {
    return SyncDeviceModel(
      id: json['id'].toString(),
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      model: json['model'] as String,
      osType: json['osType'] as String,
      osVersion: json['osVersion'] as String,
      appVersion: json['appVersion'] as String,
      userId: json['userId'].toString()
    );
  }

  Map<String, dynamic> toRequestJson({String? pushToken}) {
    return {
      'uuid': uuid,
      'name': name,
      'model': model,
      'osType': osType,
      'osVersion': osVersion,
      'appVersion': appVersion,
      if (pushToken != null && pushToken.isNotEmpty) 'pushToken': pushToken
    };
  }

  factory SyncDeviceModel.fromEntity(SyncDevice device) {
    return SyncDeviceModel(
      id: device.id,
      uuid: device.uuid,
      name: device.name,
      model: device.model,
      osType: device.osType,
      osVersion: device.osVersion,
      appVersion: device.appVersion,
      userId: device.userId
    );
  }
}