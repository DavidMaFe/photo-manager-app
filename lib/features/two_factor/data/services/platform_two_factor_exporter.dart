import 'package:share_plus/share_plus.dart';
import 'package:photo_manager_app/features/two_factor/domain/services/two_factor_exporter.dart';
import 'package:url_launcher/url_launcher.dart';

/// The otpauth link opens the authenticator app of the phone (Google Authenticator, Microsoft Authenticator...); the
/// codes go to the share sheet.
class PlatformTwoFactorExporter implements TwoFactorExporter {
  @override
  Future<bool> openInAuthenticator(String otpauthUri) async {
    try {
      return await launchUrl(Uri.parse(otpauthUri), mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> shareBackupCodes(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
