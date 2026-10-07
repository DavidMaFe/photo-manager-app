import 'dart:io';

import 'package:credential_manager/credential_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_manager_app/features/account_security/domain/services/recovery_phrase_exporter.dart';
import 'package:share_plus/share_plus.dart';

/// Google Password Manager (Credential Manager) and a shared PDF.
class PlatformRecoveryPhraseExporter implements RecoveryPhraseExporter {
  final CredentialManager credentialManager;

  PlatformRecoveryPhraseExporter({CredentialManager? credentialManager})
      : credentialManager = credentialManager ?? CredentialManager();

  @override
  Future<bool> saveToPasswordManager({required String account, required List<String> words}) async {
    try {
      if (!credentialManager.isSupportedPlatform) {
        return false;
      }
      await credentialManager.init(preferImmediatelyAvailableCredentials: false);
      await credentialManager.savePasswordCredentials(PasswordCredential(username: account, password: words.join(' ')));
      return true;
    } catch (_) {
      // No Google account, the user dismissed the dialog or the platform does not allow it
      return false;
    }
  }

  @override
  Future<void> sharePdf({required String email, required List<String> words, required RecoveryPhrasePdfTexts texts}) async {
    final document = pw.Document(title: texts.title);
    document.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(texts.title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('${texts.accountLabel}: $email'),
          pw.SizedBox(height: 24),
          pw.Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (var i = 0; i < words.length; i++)
                pw.Container(
                  width: 150,
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey600)),
                  child: pw.Text('${i + 1}. ${words[i]}', style: const pw.TextStyle(fontSize: 14)),
                ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(texts.warning, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(texts.instructions),
        ],
      ),
    ));

    // Kept in the private cache until the next export or the logout: the receiving app (Drive, files...) may read it
    // after the share sheet closes
    await deleteExportedFiles();
    final file = File('${(await _exportDirectory()).path}/${texts.fileName}');
    await file.writeAsBytes(await document.save());
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')], title: texts.title));
  }

  @override
  Future<void> deleteExportedFiles() async {
    final directory = await _exportDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<Directory> _exportDirectory() async {
    final directory = Directory('${(await getTemporaryDirectory()).path}/recovery_phrase');
    return directory.create(recursive: true);
  }
}
