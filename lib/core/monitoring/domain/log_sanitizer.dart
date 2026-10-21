/// The last check of the texts of the app before they leave the device: emails, absolute paths and content URIs
/// are replaced (a path can carry the name of a photo), and the length is limited.
class LogSanitizer {
  static const int maxMessage = 1000;
  static const int maxStackTrace = 8000;
  static const int maxShort = 200;

  static final RegExp _email = RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+');
  static final RegExp _contentUri = RegExp(r'(content|file)://\S+');
  static final RegExp _absolutePath = RegExp(r'''(?<![\w:])/(?:[^\s/'"()]+/)*[^\s/'"()]+''');

  const LogSanitizer._();

  static String? clean(String? text, {int maxLength = maxMessage}) {
    if (text == null) {
      return null;
    }
    final cleaned = text
        .replaceAll(_email, '<email>')
        .replaceAll(_contentUri, '<uri>')
        .replaceAll(_absolutePath, '<path>');
    return cleaned.length > maxLength ? cleaned.substring(0, maxLength) : cleaned;
  }
}
