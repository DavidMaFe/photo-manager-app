import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/network/authenticated_http_client.dart';

/// An image of the backend that is not encrypted (the profile image, decision D3). It is downloaded with the
/// authenticated client, which takes the token from the secure storage and refreshes it on a 401. The photos and
/// videos of the user use EncryptedImage instead.
class AuthenticatedImage extends StatelessWidget {

  final String imageUrl;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final http.Client? client;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AuthenticatedNetworkImage(imageUrl, client: client ?? sl<AuthenticatedHttpClient>()),
      fit: fit ?? BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => wasSynchronouslyLoaded || frame != null
          ? child
          : (placeholder ?? _defaultPlaceholder)(context, imageUrl),
      errorBuilder: (context, error, _) => (errorWidget ?? _defaultErrorWidget)(context, imageUrl, error),
    );
  }

  Widget _defaultPlaceholder(BuildContext context, String url) {
    return Container(
      color: context.palette.media,
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: context.palette.onMedia),
      )
    );
  }

  Widget _defaultErrorWidget(BuildContext context, String url, Object error) {
    return Container(
      color: context.palette.line,
      child: Center(child: Icon(Icons.broken_image, color: context.palette.ink2, size: 32)),
    );
  }
}

/// Image downloaded with an authenticated client. Flutter's image cache keeps it in memory.
@immutable
class AuthenticatedNetworkImage extends ImageProvider<AuthenticatedNetworkImage> {
  final String url;
  final http.Client client;

  const AuthenticatedNetworkImage(this.url, {required this.client});

  @override
  Future<AuthenticatedNetworkImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<AuthenticatedNetworkImage>(this);

  @override
  ImageStreamCompleter loadImage(AuthenticatedNetworkImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(codec: _load(decode), scale: 1, debugLabel: url);
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final response = await client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw NetworkImageLoadException(statusCode: response.statusCode, uri: Uri.parse(url));
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(response.bodyBytes));
  }

  @override
  bool operator ==(Object other) => other is AuthenticatedNetworkImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
