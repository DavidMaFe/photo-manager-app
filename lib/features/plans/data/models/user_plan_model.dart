import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_limits.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';

/// `GET /api/profile/plan/`.
class UserPlanModel extends UserPlan {
  const UserPlanModel({
    required super.tier,
    required super.limits,
    required super.storedBytes,
    required super.devices,
    required super.pausedDevices,
    required super.readOnly,
    required super.subscription,
    super.billingAccountId,
  });

  factory UserPlanModel.fromJson(Map<String, dynamic> json) {
    final limits = json['limits'] as Map<String, dynamic>? ?? const {};
    final usage = json['usage'] as Map<String, dynamic>? ?? const {};
    final subscription = json['subscription'] as Map<String, dynamic>?;
    return UserPlanModel(
      tier: PlanTier.fromApi(json['plan'] as String?),
      limits: PlanLimits(
        storageBytes: (limits['storageBytes'] as num?)?.toInt() ?? 0,
        maxDevices: (limits['maxDevices'] as num?)?.toInt() ?? 0,
        maxVideoBytes: (limits['maxVideoBytes'] as num?)?.toInt() ?? 0,
        dailyBackup: limits['dailyBackup'] as bool? ?? false,
      ),
      storedBytes: (usage['storedBytes'] as num?)?.toInt() ?? 0,
      devices: (usage['devices'] as num?)?.toInt() ?? 0,
      pausedDevices: [for (final uuid in usage['pausedDevices'] as List? ?? const []) uuid as String],
      readOnly: json['readOnly'] as bool? ?? false,
      subscription: subscription == null
          ? null
          : PlanSubscription(
              tier: PlanTier.fromApi(subscription['plan'] as String?),
              status: SubscriptionStatus.fromApi(subscription['status'] as String?),
              // «plus_100:monthly»: product and base plan of the store
              period: BillingPeriod.fromBasePlan((subscription['productId'] as String?)?.split(':').last),
              periodEnd: DateTime.tryParse(subscription['periodEnd'] as String? ?? ''),
              autoRenewing: subscription['autoRenewing'] as bool? ?? false,
            ),
      billingAccountId: json['billingAccountId'] as String?,
    );
  }
}
