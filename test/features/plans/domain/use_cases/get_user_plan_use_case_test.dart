import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/plan_repository.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/get_user_plan_use_case.dart';

import '../../../../helpers/plan_test_providers.dart';

class MockPlanRepository extends Mock implements PlanRepository {}

void main() {
  test('GetUserPlanUseCase should read the plan from the repository', () async {
    final repository = MockPlanRepository();
    when(() => repository.getUserPlan()).thenAnswer((_) async => TestPlans.plus100);

    expect(await GetUserPlanUseCase(repository)(), TestPlans.plus100);
  });
}
