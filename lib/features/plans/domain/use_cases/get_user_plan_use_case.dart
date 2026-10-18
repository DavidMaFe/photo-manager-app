import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/plan_repository.dart';

class GetUserPlanUseCase {
  final PlanRepository _repository;

  GetUserPlanUseCase(this._repository);

  Future<UserPlan> call() => _repository.getUserPlan();
}
