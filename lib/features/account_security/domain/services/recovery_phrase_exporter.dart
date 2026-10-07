/// Texts of the PDF with the 24 words, already translated by the presentation layer.
class RecoveryPhrasePdfTexts {
  final String title;
  final String accountLabel;
  final String warning;
  final String instructions;
  final String fileName;

  const RecoveryPhrasePdfTexts({
    required this.title,
    required this.accountLabel,
    required this.warning,
    required this.instructions,
    required this.fileName,
  });
}

/// Keeps the 24 words outside the app (decision of 7 Oct 2026).
abstract class RecoveryPhraseExporter {
  /// Saves the words in the password manager of the system (Google Password Manager on Android).
  /// Returns false if the platform or the user does not allow it.
  Future<bool> saveToPasswordManager({required String account, required List<String> words});

  /// Creates a PDF with the words and opens the share sheet (Drive, files, print...).
  Future<void> sharePdf({required String email, required List<String> words, required RecoveryPhrasePdfTexts texts});

  /// Removes the exported PDF from the private cache of the app (logout).
  Future<void> deleteExportedFiles();
}
