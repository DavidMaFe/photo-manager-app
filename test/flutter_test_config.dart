import 'dart:async';
import 'dart:typed_data';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/network/authenticated_http_client.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';

/// The pages show the photos with EncryptedImage, which takes LoadMediaUseCase from the dependency container. In the
/// widget tests nothing is downloaded: the fake fails at once, so the images show their error placeholder (a static
/// icon) instead of a spinner that would never settle. The tests of the encrypted images inject their own use case.
class _OfflineLoadMediaUseCase extends Mock implements LoadMediaUseCase {
  @override
  Future<Uint8List> call(String fileId, MediaVariant variant) => Future.error(StateError('Offline in tests'));
}

/// The profile image (AuthenticatedImage) is downloaded with the authenticated client: offline as well.
class _OfflineHttpClient extends Mock implements AuthenticatedHttpClient {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) => Future.error(StateError('Offline in tests'));
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final sl = GetIt.instance;
  if (!sl.isRegistered<LoadMediaUseCase>()) {
    sl.registerSingleton<LoadMediaUseCase>(_OfflineLoadMediaUseCase());
  }
  if (!sl.isRegistered<AuthenticatedHttpClient>()) {
    sl.registerSingleton<AuthenticatedHttpClient>(_OfflineHttpClient());
  }
  await testMain();
}
