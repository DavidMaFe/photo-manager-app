import 'dart:convert';

import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';

/// JSON of the Argon2id parameters (GET /api/auth/kdf-params/ and request bodies).
class KdfParamsModel {
  const KdfParamsModel._();

  /// `{ kdfSalt, algorithm, ops, memBytes }`
  static KdfParams fromJson(Map<String, dynamic> json) {
    return KdfParams(
      salt: base64Decode(json['kdfSalt'] as String),
      algorithm: json['algorithm'] as String,
      ops: json['ops'] as int,
      memBytes: (json['memBytes'] as num).toInt(),
    );
  }

  /// `{ algorithm, ops, memBytes }`; the salt travels apart as `kdfSalt`.
  static Map<String, dynamic> paramsToJson(KdfParams params) {
    return {'algorithm': params.algorithm, 'ops': params.ops, 'memBytes': params.memBytes};
  }

  static String saltToJson(KdfParams params) => base64Encode(params.salt);
}
