import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/file_metadata.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/video_stream_server.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/get_file_metadata_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_image.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_photo_viewer.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/video_player_widget.dart';

import '../../../helpers/widget_test_helper.dart';

class MockLoadMediaUseCase extends Mock implements LoadMediaUseCase {}

class MockGetFileMetadataUseCase extends Mock implements GetFileMetadataUseCase {}

class MockVideoStreamServer extends Mock implements VideoStreamServer {}

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

/// A valid 1×1 PNG, as the decrypted bytes of a photo.
final Uint8List onePixelPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');

void main() {
  late MockLoadMediaUseCase loadMedia;

  setUpAll(() {
    registerFallbackValue(MediaVariant.thumbnail);
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    loadMedia = MockLoadMediaUseCase();
    // Each test uses its own provider instances: nothing from the previous one stays in the image cache
    PaintingBinding.instance.imageCache.clear();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(makeTestableWidget(SizedBox(width: 200, height: 200, child: child)));
  }

  group('EncryptedImage', () {
    testWidgets('should show a spinner while the image is decrypted', (tester) async {
      when(() => loadMedia(any(), any())).thenAnswer((_) => Completer<Uint8List>().future);

      await pump(tester, EncryptedImage(fileId: '1', loadMedia: loadMedia));

      expect(find.byKey(const ValueKey('encrypted-image-loading')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show nothing while loading in tiles that paint their own background', (tester) async {
      when(() => loadMedia(any(), any())).thenAnswer((_) => Completer<Uint8List>().future);

      await pump(tester, EncryptedImage(fileId: '1', loadMedia: loadMedia, transparentWhileLoading: true));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show the decrypted image', (tester) async {
      when(() => loadMedia('1', MediaVariant.thumbnail)).thenAnswer((_) async => onePixelPng);

      await tester.runAsync(() async {
        await pump(tester, EncryptedImage(fileId: '1', loadMedia: loadMedia));
        await precacheImage(
            (tester.widget<Image>(find.byType(Image))).image, tester.element(find.byType(EncryptedImage)));
      });
      await tester.pump();

      expect(find.byKey(const ValueKey('encrypted-image-loading')), findsNothing);
      expect(find.byKey(const ValueKey('encrypted-image-error')), findsNothing);
      verify(() => loadMedia('1', MediaVariant.thumbnail)).called(1);
    });

    testWidgets('should show a lock for a file of a locked key version', (tester) async {
      when(() => loadMedia(any(), any())).thenAnswer((_) => Future.error(const LockedFileFailure()));

      await pump(tester, EncryptedImage(fileId: '1', loadMedia: loadMedia, hideErrors: true));
      await tester.pump();

      // Even where errors are hidden: the user must know it is locked, not lost
      expect(find.byKey(const ValueKey('encrypted-image-locked')), findsOneWidget);
      expect(find.byTooltip('Locked: recover it from Profile > Security'), findsOneWidget);
    });

    testWidgets('should show the error placeholder, or nothing in mosaics', (tester) async {
      when(() => loadMedia(any(), any())).thenAnswer((_) => Future.error(Exception('network')));

      await pump(tester, EncryptedImage(fileId: '1', loadMedia: loadMedia));
      await tester.pump();
      expect(find.byTooltip('It could not be loaded'), findsOneWidget);

      await pump(tester, EncryptedImage(fileId: '2', loadMedia: loadMedia, hideErrors: true));
      await tester.pump();
      expect(find.byKey(const ValueKey('encrypted-image-error')), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('EncryptedPhotoViewer', () {
    testWidgets('should show the thumbnail while the original is decrypted', (tester) async {
      when(() => loadMedia('1', MediaVariant.original)).thenAnswer((_) => Completer<Uint8List>().future);
      when(() => loadMedia('1', MediaVariant.thumbnail)).thenAnswer((_) => Completer<Uint8List>().future);

      await pump(tester, EncryptedPhotoViewer(fileId: '1', loadMedia: loadMedia));
      await tester.pump();

      expect(find.byKey(const ValueKey('encrypted-image-1-thumbnail')), findsOneWidget);
      verify(() => loadMedia('1', MediaVariant.original)).called(1);
      verify(() => loadMedia('1', MediaVariant.thumbnail)).called(1);
    });

    testWidgets('should keep the thumbnail when the original fails', (tester) async {
      when(() => loadMedia('1', MediaVariant.original)).thenAnswer((_) => Future.error(Exception('network')));
      when(() => loadMedia('1', MediaVariant.thumbnail)).thenAnswer((_) => Completer<Uint8List>().future);

      await pump(tester, EncryptedPhotoViewer(fileId: '1', loadMedia: loadMedia));
      await tester.pump();

      expect(find.byKey(const ValueKey('encrypted-image-1-thumbnail')), findsOneWidget);
    });
  });

  group('AuthenticatedImage', () {
    testWidgets('should download the profile image with the authenticated client', (tester) async {
      final client = MockHttpClient();
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response.bytes(onePixelPng, 200));

      await tester.runAsync(() async {
        await pump(tester, AuthenticatedImage(imageUrl: 'http://server/api/profile/profile-image/', client: client));
        await precacheImage(tester.widget<Image>(find.byType(Image)).image,
            tester.element(find.byType(AuthenticatedImage)));
      });

      verify(() => client.get(Uri.parse('http://server/api/profile/profile-image/'))).called(1);
    });

    testWidgets('should show the error widget when the download fails', (tester) async {
      final client = MockHttpClient();
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('', 403));

      await tester.runAsync(() async {
        await pump(tester, AuthenticatedImage(imageUrl: 'http://server/x', client: client,
            errorWidget: (_, __, ___) => const Text('no photo')));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('no photo'), findsOneWidget);
    });
  });

  group('VideoPlayerWidget', () {
    testWidgets('should play through the local proxy with the decrypted MIME type', (tester) async {
      final server = MockVideoStreamServer();
      final metadata = MockGetFileMetadataUseCase();
      when(() => metadata('3')).thenAnswer((_) async => const FileMetadata(name: 'a.mov', mimeType: 'video/quicktime'));
      when(() => server.urlFor(any(), mimeType: any(named: 'mimeType')))
          .thenAnswer((_) async => Uri.parse('http://127.0.0.1:5000/v/token'));

      await tester.pumpWidget(makeTestableWidget(VideoPlayerWidget(
        fileId: '3',
        onControlsVisibilityChanged: null,
        videoStreamServer: server,
        getFileMetadata: metadata,
      )));
      await tester.pump();
      await tester.pump();

      verify(() => server.urlFor('3', mimeType: 'video/quicktime')).called(1);
    });

    testWidgets('should still ask the proxy when the metadata cannot be read', (tester) async {
      final server = MockVideoStreamServer();
      final metadata = MockGetFileMetadataUseCase();
      when(() => metadata('3')).thenAnswer((_) => Future.error(const LockedFileFailure()));
      when(() => server.urlFor(any(), mimeType: any(named: 'mimeType')))
          .thenAnswer((_) async => Uri.parse('http://127.0.0.1:5000/v/token'));

      await tester.pumpWidget(makeTestableWidget(VideoPlayerWidget(
        fileId: '3',
        onControlsVisibilityChanged: null,
        videoStreamServer: server,
        getFileMetadata: metadata,
      )));
      await tester.pump();
      await tester.pump();

      verify(() => server.urlFor('3', mimeType: null)).called(1);
    });
  });
}
