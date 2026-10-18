import 'package:photo_manager_app/features/plans/data/data_sources/plan_remote_data_source.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/plan_repository.dart';

class PlanDataRepository implements PlanRepository {
  final PlanRemoteDataSource remoteDataSource;

  PlanDataRepository({required this.remoteDataSource});

  @override
  Future<UserPlan> getUserPlan() => remoteDataSource.getUserPlan();
}
