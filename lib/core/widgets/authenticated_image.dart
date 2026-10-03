import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthenticatedImage extends StatelessWidget {

  final String imageUrl;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this. imageUrl,
    this.fit,
    this.placeholder,
    this.errorWidget
  });

  String _getToken() {
    try {
      final prefs = GetIt.instance<SharedPreferences>();
      return prefs.getString("AUTH_TOKEN") ?? '';
    } catch(e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {

    final token = _getToken();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: {
        'Authorization': 'Bearer $token'
      },
      fit: fit ?? BoxFit.cover,
      placeholder: placeholder ?? _defaultPlaceholder,
      errorWidget: errorWidget?? _defaultErrorWidget,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: context.palette.ink2,
            size: 32
          ),
          const SizedBox(height: 4),
          Text('Error', style: TextStyle(
            color: context.palette.ink2,
            fontSize: 10
          ))
        ],
      ),
    );
  }
}