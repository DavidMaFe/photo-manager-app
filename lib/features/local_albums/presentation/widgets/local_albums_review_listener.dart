import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/check_local_albums_review_use_case.dart';

/// Opens «Tus álbumes» once per account and device (ROADMAP-local-albums.md): after the onboarding, or at the first
/// start after the update. Checked once per app session, when the main screens open. Without a connection it is
/// asked again at the next start.
class LocalAlbumsReviewListener extends StatefulWidget {
  final Widget child;
  final Future<List<LocalAlbum>?> Function()? check;

  const LocalAlbumsReviewListener({super.key, required this.child, this.check});

  static bool checkedThisSession = false;

  @override
  State<LocalAlbumsReviewListener> createState() => _LocalAlbumsReviewListenerState();
}

class _LocalAlbumsReviewListenerState extends State<LocalAlbumsReviewListener> {
  @override
  void initState() {
    super.initState();
    if (!LocalAlbumsReviewListener.checkedThisSession) {
      LocalAlbumsReviewListener.checkedThisSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  Future<void> _check() async {
    List<LocalAlbum>? albums;
    try {
      albums = await (widget.check ?? sl<CheckLocalAlbumsReviewUseCase>().call)();
    } catch (_) {
      return;
    }
    if (albums == null || !mounted) return;
    context.pushNamed(RouteNames.localAlbumsReview, extra: albums);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
