import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';

abstract class PlanRepository {
  Future<UserPlan> getUserPlan();
}
