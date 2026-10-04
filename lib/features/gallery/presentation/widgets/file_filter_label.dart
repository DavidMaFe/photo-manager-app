import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Localized label of each gallery filter.
extension FileFilterLabel on FileFilter {
  String label(AppLocalizations l10n) {
    switch (this) {
      case FileFilter.all:
        return l10n.filterAll;
      case FileFilter.favorites:
        return l10n.filterFavorites;
      case FileFilter.images:
        return l10n.photos;
      case FileFilter.videos:
        return l10n.videos;
      case FileFilter.pending:
        return l10n.filterToReview;
    }
  }
}
