/// Plays encrypted videos with the system player: a local HTTP address that decrypts the requested ranges on the fly
/// (docs/e2ee-spec.md, section 11).
abstract class VideoStreamServer {
  /// Address only valid inside this app (127.0.0.1, random port and token).
  Future<Uri> urlFor(String fileId, {String? mimeType});

  Future<void> stop();
}
