import 'dart:ffi';
import 'dart:io';

import 'package:sodium/sodium_sumo.dart';

/// libsodium for unit tests on the host machine (the Flutter plugin only loads it on devices).
///
/// macOS: `brew install libsodium`. Linux: `apt install libsodium23`. The path can be overridden with LIBSODIUM_PATH.
Future<SodiumSumo> loadTestSodium() {
  return SodiumSumoInit.init(() => DynamicLibrary.open(_libsodiumPath()));
}

String _libsodiumPath() {
  final override = Platform.environment['LIBSODIUM_PATH'];
  if (override != null && override.isNotEmpty) {
    return override;
  }
  const candidates = [
    '/opt/homebrew/lib/libsodium.dylib',
    '/usr/local/lib/libsodium.dylib',
    '/usr/lib/x86_64-linux-gnu/libsodium.so.23',
    '/usr/lib/aarch64-linux-gnu/libsodium.so.23',
  ];
  for (final candidate in candidates) {
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }
  throw StateError('libsodium not found for the unit tests. Install it (brew install libsodium) or set LIBSODIUM_PATH.');
}
