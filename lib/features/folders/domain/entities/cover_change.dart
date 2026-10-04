import 'package:equatable/equatable.dart';

import '../enums/cover_change_action.dart';


/// Change of one album's covers for one photo.
class CoverChange extends Equatable {

  final String folderId;
  final CoverChangeAction action;

  /// Cover replaced by the photo; only for [CoverChangeAction.replace].
  final String? replaceFileId;

  const CoverChange({required this.folderId, required this.action, this.replaceFileId});

  const CoverChange.add(this.folderId) : action = CoverChangeAction.add, replaceFileId = null;
  const CoverChange.remove(this.folderId) : action = CoverChangeAction.remove, replaceFileId = null;
  const CoverChange.replace(this.folderId, String this.replaceFileId) : action = CoverChangeAction.replace;

  @override
  List<Object?> get props => [folderId, action, replaceFileId];
}
