import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/data/data_sources/plan_remote_data_source.dart';
import 'package:photo_manager_app/features/plans/data/models/user_plan_model.dart';
import 'package:photo_manager_app/features/plans/data/repositories/plan_data_repository.dart';

class MockPlanRemoteDataSource extends Mock implements PlanRemoteDataSource {}

void main() {
  test('PlanDataRepository should return the plan of the server', () async {
    final remote = MockPlanRemoteDataSource();
    final model = UserPlanModel.fromJson(const {'plan': 'FREE'});
    when(() => remote.getUserPlan()).thenAnswer((_) async => model);

    expect(await PlanDataRepository(remoteDataSource: remote).getUserPlan(), model);
  });
}
