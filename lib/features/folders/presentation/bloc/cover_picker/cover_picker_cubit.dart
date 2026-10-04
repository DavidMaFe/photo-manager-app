import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/apply_cover_changes_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_cover_targets_use_case.dart';

import 'cover_picker_state.dart';


/// "Use as cover" sheet: the albums 1–3 photos can be covers of, which ones
/// are ticked, the covers to replace in full albums, and saving.
class CoverPickerCubit extends Cubit<CoverPickerState> {

  final GetCoverTargetsUseCase getCoverTargetsUseCase;
  final ApplyCoverChangesUseCase applyCoverChangesUseCase;
  final AppEventBus eventBus;

  CoverPickerCubit({
    required this.getCoverTargetsUseCase,
    required this.applyCoverChangesUseCase,
    required this.eventBus,
  }) : super(const CoverPickerState());

  Future<void> load(List<String> fileIds) async {
    emit(CoverPickerState(fileIds: fileIds));
    try {
      final targets = await getCoverTargetsUseCase(fileIds);
      if (targets.isEmpty) {
        emit(state.copyWith(status: CoverPickerStatus.noSharedAlbum));
        return;
      }
      emit(state.copyWith(
        status: CoverPickerStatus.ready,
        targets: targets,
        checked: {
          for (final target in targets)
            if (fileIds.every(target.hasCover)) target.folderId,
        },
      ));
    } catch (e) {
      emit(state.copyWith(status: CoverPickerStatus.failure, failure: ErrorHandler.handleError(e)));
    }
  }

  /// Ticks or unticks an album. Unticking forgets its chosen replacements.
  void toggle(String folderId) {
    if (state.status != CoverPickerStatus.ready) return;
    final checked = {...state.checked};
    if (!checked.remove(folderId)) checked.add(folderId);
    emit(state.copyWith(
      checked: checked,
      replacements: {...state.replacements}..remove(folderId),
    ));
  }

  /// Chooses (or un-chooses) a cover to replace in a full album. With one
  /// replacement needed it works like a radio button.
  void chooseReplacement(String folderId, String coverFileId) {
    if (state.status != CoverPickerStatus.ready) return;
    final target = state.targets.firstWhere((t) => t.folderId == folderId);
    final needed = state.replacementsNeeded(target);
    if (needed == 0 || !state.replaceableCovers(target).contains(coverFileId)) return;

    var chosen = [...state.replacementsOf(target)];
    if (chosen.contains(coverFileId)) {
      chosen.remove(coverFileId);
    } else {
      chosen.add(coverFileId);
      if (chosen.length > needed) chosen = chosen.sublist(chosen.length - needed);
    }
    emit(state.copyWith(replacements: {...state.replacements, folderId: chosen}));
  }

  Future<void> save() async {
    if (!state.canSave) return;
    final changedFolders = [for (final t in state.targets) if (state.hasChange(t)) t.folderId];
    emit(state.copyWith(status: CoverPickerStatus.saving));
    try {
      final folders = await applyCoverChangesUseCase(
        targets: state.targets,
        changesByFile: state.changesByFile(),
      );
      eventBus.fire(CoversChangedEvent(folderIds: changedFolders));
      emit(state.copyWith(status: CoverPickerStatus.saved, savedFolders: folders));
    } catch (e) {
      emit(state.copyWith(status: CoverPickerStatus.ready, failure: ErrorHandler.handleError(e)));
    }
  }
}
