import 'dart:io';

import 'package:flutter/services.dart';

/// Keeps a screen that shows secrets (recovery words, backup codes, the TOTP key) out of screenshots, screen
/// recordings and the recent apps (docs/security-audit-2026-10.md, A2). On Android it sets FLAG_SECURE on the window
/// (MainActivity); elsewhere it does nothing.
class SecureScreen {
  static const String channelName = 'com.photomanagerpro.app/secure_screen';

  final MethodChannel channel;
  final bool enabled;

  SecureScreen({MethodChannel? channel, bool? enabled})
      : channel = channel ?? const MethodChannel(channelName),
        enabled = enabled ?? Platform.isAndroid;

  Future<void> enable() => _call('enable');

  /// Each [enable] needs its [disable]: the window stays protected while any protected screen is open.
  Future<void> disable() => _call('disable');

  Future<void> _call(String method) async {
    if (!enabled) return;
    try {
      await channel.invokeMethod<void>(method);
    } on PlatformException {
      // The screen still works without the protection
    } on MissingPluginException {
      // Same: an engine without the channel (tests, a background isolate)
    }
  }
}
