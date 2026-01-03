import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';


enum FileFilter {
  all,
  images,
  videos,
  pending;

  FileType? get fileType {
    switch (this) {
      case FileFilter.images:
        return FileType.image;
      case FileFilter.videos:
        return FileType.video;
      default:
        return null;
    }
  }

  FileStatus? get fileStatus {
    switch (this) {
      case FileFilter.pending:
        return FileStatus.pending;
      default:
        return null;
    }
  }

  // TODO: Gestionar con l10n
  String get displayName {
    switch (this) {
      case FileFilter.all:
        return 'Todos';
      case FileFilter.images:
        return 'Fotos';
      case FileFilter.videos:
        return 'Videos';
      case FileFilter.pending:
        return 'Pendientes';
    }
  }

  IconData? get icon {
    switch (this) {
      case FileFilter.all:
        return null;
      case FileFilter.images:
        return Icons.photo;
      case FileFilter.videos:
        return Icons.videocam;
      case FileFilter.pending:
        return Icons.schedule;
    }
  }
}