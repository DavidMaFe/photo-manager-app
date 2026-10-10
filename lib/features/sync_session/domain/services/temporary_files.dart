import 'dart:io';

/// Private temporary files of the app, for the encrypted copy of a file while it is uploaded.
abstract class TemporaryFiles {
  /// A new empty file; the caller deletes it.
  Future<File> create(String suffix);
}
