import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';

/// State of a subscription as the store reports it.
enum SubscriptionStatus {
  /// Bought but not paid yet (e.g. cash in a shop): it gives nothing until it is paid.
  pending('PENDING'),
  active('ACTIVE'),
  canceled('CANCELED'),
  inGracePeriod('IN_GRACE_PERIOD'),
  onHold('ON_HOLD'),
  paused('PAUSED'),
  expired('EXPIRED'),
  revoked('REVOKED');

  final String apiName;

  const SubscriptionStatus(this.apiName);

  static SubscriptionStatus fromApi(String? apiName) =>
      values.firstWhere((status) => status.apiName == apiName, orElse: () => SubscriptionStatus.expired);
}

/// The subscription behind the plan, or the latest one on the free plan.
class PlanSubscription extends Equatable {
  final PlanTier tier;
  final SubscriptionStatus status;

  /// Monthly or annual; null when unknown.
  final BillingPeriod? period;

  /// End of the period paid: the next renewal, or when the plan ends if it does not renew.
  final DateTime? periodEnd;
  final bool autoRenewing;

  const PlanSubscription({
    required this.tier,
    required this.status,
    this.period,
    required this.periodEnd,
    required this.autoRenewing,
  });

  /// The store will charge it again (deleting the account cancels it).
  bool get renews =>
      autoRenewing &&
      const {SubscriptionStatus.active, SubscriptionStatus.inGracePeriod, SubscriptionStatus.onHold,
          SubscriptionStatus.paused}.contains(status);

  @override
  List<Object?> get props => [tier, status, period, periodEnd, autoRenewing];
}
