import 'package:photo_manager_app/features/encrypted_media/domain/repositories/encrypted_media_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/decrypted_range_reader.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/file_key_unwrapper.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/video_stream_server.dart';

/// At logout: forgets the keys of the files, stops the video proxy and empties the encrypted cache.
class ClearMediaDataUseCase {
  final FileKeyRepository _fileKeyRepository;
  final FileKeyUnwrapper _keyUnwrapper;
  final DecryptedRangeReader _rangeReader;
  final VideoStreamServer _videoStreamServer;
  final EncryptedMediaRepository _mediaRepository;

  ClearMediaDataUseCase(this._fileKeyRepository, this._keyUnwrapper, this._rangeReader, this._videoStreamServer,
      this._mediaRepository);

  Future<void> call() async {
    _keyUnwrapper.clear();
    _rangeReader.clear();
    _fileKeyRepository.clear();
    await _videoStreamServer.stop();
    await _mediaRepository.clearCache();
  }
}
