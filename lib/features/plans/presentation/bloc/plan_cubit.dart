import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/get_user_plan_use_case.dart';

class PlanState extends Equatable {
  /// The last plan read; it stays while a new read fails, so the screens keep their limits.
  final UserPlan? plan;
  final bool loading;
  final Failure? failure;

  /// UUID of this device, to know whether it is paused.
  final String? deviceUuid;

  const PlanState({this.plan, this.loading = false, this.failure, this.deviceUuid});

  /// This device is linked but cannot back up: more linked devices than the plan allows.
  bool get isThisDevicePaused => deviceUuid != null && (plan?.isPaused(deviceUuid!) ?? false);

  @override
  List<Object?> get props => [plan, loading, failure, deviceUuid];
}

/// The plan of the user, shared by the profile, the plans page, the backup settings and the backup. Read when the
/// session starts, when the app comes back and after a backup hits a limit of the plan.
class PlanCubit extends Cubit<PlanState> {
  final GetUserPlanUseCase _getUserPlan;
  final Future<String> Function() _deviceUuid;

  PlanCubit({required GetUserPlanUseCase getUserPlan, required Future<String> Function() deviceUuid})
      : _getUserPlan = getUserPlan,
        _deviceUuid = deviceUuid,
        super(const PlanState());

  Future<UserPlan?> load() async {
    emit(PlanState(plan: state.plan, loading: true, deviceUuid: state.deviceUuid));
    try {
      final plan = await _getUserPlan();
      final deviceUuid = state.deviceUuid ?? await _deviceUuid();
      emit(PlanState(plan: plan, deviceUuid: deviceUuid));
      return plan;
    } catch (e) {
      emit(PlanState(plan: state.plan, failure: ErrorHandler.handleError(e), deviceUuid: state.deviceUuid));
      return state.plan;
    }
  }

  /// The plan answered by the server after a purchase.
  void show(UserPlan plan) => emit(PlanState(plan: plan, deviceUuid: state.deviceUuid));

  /// The session ended: nothing of the previous user stays.
  void clear() => emit(const PlanState());
}
