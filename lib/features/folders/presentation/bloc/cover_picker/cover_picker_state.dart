import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_change.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_target.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_covers.dart';


enum CoverPickerStatus {
  loading,
  ready,
  saving,

  /// Changes saved: the sheet closes with [CoverPickerState.savedFolders].
  saved,

  /// The albums could not load.
  failure,

  /// Several photos without a common album: the sheet does not open.
  noSharedAlbum,
}

/// What will happen to an album of the tree (its status line).
enum CoverRowStatus {
  /// Already a cover and still ticked.
  alreadyCover,

  /// Will be added and there is room.
  willAdd,

  /// Will be added to a full album: covers to replace are missing.
  needsReplacement,

  /// Will be removed from the covers.
  willRemove,

  /// No change and not a cover.
  unchanged,
}


class CoverPickerState extends Equatable {

  final CoverPickerStatus status;

  /// Photos to use as cover (1–3).
  final List<String> fileIds;

  /// Albums they can be covers of, root first.
  final List<CoverTarget> targets;

  /// Albums ticked now.
  final Set<String> checked;

  /// Covers chosen to be replaced in each full album.
  final Map<String, List<String>> replacements;

  /// Final covers of the changed albums, once saved.
  final List<FolderCovers> savedFolders;

  /// One-shot error of the last load or save.
  final Failure? failure;

  const CoverPickerState({
    this.status = CoverPickerStatus.loading,
    this.fileIds = const [],
    this.targets = const [],
    this.checked = const {},
    this.replacements = const {},
    this.savedFolders = const [],
    this.failure,
  });

  /// Ticked when the sheet opened: every photo already is a cover of it.
  bool initiallyChecked(CoverTarget target) => fileIds.every(target.hasCover);

  bool isChecked(CoverTarget target) => checked.contains(target.folderId);

  bool hasChange(CoverTarget target) => isChecked(target) != initiallyChecked(target);

  /// Photos that are not covers of [target] yet.
  List<String> missing(CoverTarget target) => fileIds.where((id) => !target.hasCover(id)).toList();

  /// Covers to replace so every photo fits in [target].
  int replacementsNeeded(CoverTarget target) {
    if (!isChecked(target) || initiallyChecked(target)) return 0;
    final free = kMaxAlbumCovers - target.covers.length;
    return max(0, missing(target).length - free);
  }

  /// Current covers of [target] that can be replaced (not the photos themselves).
  List<String> replaceableCovers(CoverTarget target) =>
      [for (final cover in target.covers) if (!fileIds.contains(cover.fileId)) cover.fileId];

  List<String> replacementsOf(CoverTarget target) => replacements[target.folderId] ?? const [];

  CoverRowStatus rowStatus(CoverTarget target) {
    final initially = initiallyChecked(target);
    if (isChecked(target)) {
      if (initially) return CoverRowStatus.alreadyCover;
      return replacementsOf(target).length < replacementsNeeded(target)
          ? CoverRowStatus.needsReplacement
          : CoverRowStatus.willAdd;
    }
    return initially ? CoverRowStatus.willRemove : CoverRowStatus.unchanged;
  }

  /// Covers the album will have after adding the photos.
  int coverCountAfterAdding(CoverTarget target) =>
      min(kMaxAlbumCovers, target.covers.length + missing(target).length);

  /// Covers [target] will have after saving, in order (the photos where they
  /// will go). While replacements are missing, only the photos that fit.
  List<String> previewCovers(CoverTarget target) {
    final ids = [for (final cover in target.covers) cover.fileId];
    if (!hasChange(target)) return ids;
    if (!isChecked(target)) return ids.where((id) => !fileIds.contains(id)).toList();

    final toAdd = missing(target);
    final chosen = replacementsOf(target);
    final firstReplaced = toAdd.length - chosen.length;
    for (var i = 0; i < chosen.length; i++) {
      ids[ids.indexOf(chosen[i])] = toAdd[firstReplaced + i];
    }
    ids.addAll(toAdd.take(firstReplaced).take(kMaxAlbumCovers - ids.length));
    return ids;
  }

  int get changeCount => targets.where(hasChange).length;

  bool get canSave =>
      status == CoverPickerStatus.ready &&
      changeCount > 0 &&
      targets.every((target) => rowStatus(target) != CoverRowStatus.needsReplacement);

  /// Changes to send for each photo. In a full album the chosen covers are
  /// replaced by the last photos; the others are added in the free places.
  Map<String, List<CoverChange>> changesByFile() {
    final changes = {for (final id in fileIds) id: <CoverChange>[]};
    for (final target in targets.where(hasChange)) {
      if (isChecked(target)) {
        final toAdd = missing(target);
        final toReplace = replacementsOf(target);
        final firstReplaced = toAdd.length - toReplace.length;
        for (var i = 0; i < toAdd.length; i++) {
          changes[toAdd[i]]!.add(i < firstReplaced
              ? CoverChange.add(target.folderId)
              : CoverChange.replace(target.folderId, toReplace[i - firstReplaced]));
        }
      } else {
        for (final id in fileIds) {
          changes[id]!.add(CoverChange.remove(target.folderId));
        }
      }
    }
    return changes;
  }

  CoverPickerState copyWith({
    CoverPickerStatus? status,
    List<String>? fileIds,
    List<CoverTarget>? targets,
    Set<String>? checked,
    Map<String, List<String>>? replacements,
    List<FolderCovers>? savedFolders,
    Failure? failure,
  }) {
    // The failure is one-shot: it is dropped on every other change.
    return CoverPickerState(
      status: status ?? this.status,
      fileIds: fileIds ?? this.fileIds,
      targets: targets ?? this.targets,
      checked: checked ?? this.checked,
      replacements: replacements ?? this.replacements,
      savedFolders: savedFolders ?? this.savedFolders,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, fileIds, targets, checked, replacements, savedFolders, failure];
}
