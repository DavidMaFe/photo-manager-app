import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/plan_download_use_case.dart';

abstract class DownloadPlanState extends Equatable {
  /// Whether the subalbums are counted (only for an album).
  final bool includeSubfolders;

  const DownloadPlanState({required this.includeSubfolders});

  @override
  List<Object?> get props => [includeSubfolders];
}

class DownloadPlanLoading extends DownloadPlanState {
  const DownloadPlanLoading({required super.includeSubfolders});
}

class DownloadPlanLoaded extends DownloadPlanState {
  final DownloadPlan plan;

  const DownloadPlanLoaded(this.plan, {required super.includeSubfolders});

  @override
  List<Object?> get props => [plan, includeSubfolders];
}

class DownloadPlanError extends DownloadPlanState {
  final Failure failure;

  const DownloadPlanError(this.failure, {required super.includeSubfolders});

  @override
  List<Object?> get props => [failure, includeSubfolders];
}

/// What the sheet «Save to this phone» would download: of an album ([folderId], with or without its subalbums) or
/// of every file of the account.
class DownloadPlanCubit extends Cubit<DownloadPlanState> {
  final PlanDownloadUseCase _planDownload;
  final String? folderId;

  DownloadPlanCubit(this._planDownload, {this.folderId, bool includeSubfolders = true})
      : super(DownloadPlanLoading(includeSubfolders: includeSubfolders));

  Future<void> load() async {
    final includeSubfolders = state.includeSubfolders;
    emit(DownloadPlanLoading(includeSubfolders: includeSubfolders));
    try {
      final plan = await _planDownload(folderId: folderId, includeSubfolders: includeSubfolders);
      if (state.includeSubfolders == includeSubfolders) {
        emit(DownloadPlanLoaded(plan, includeSubfolders: includeSubfolders));
      }
    } catch (e) {
      emit(DownloadPlanError(ErrorHandler.handleError(e), includeSubfolders: includeSubfolders));
    }
  }

  Future<void> setIncludeSubfolders(bool value) async {
    if (value == state.includeSubfolders) return;
    emit(DownloadPlanLoading(includeSubfolders: value));
    await load();
  }
}
