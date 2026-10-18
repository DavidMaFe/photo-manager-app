import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_limits.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';

/// The plan of the user, its limits and what the user uses of them.
class UserPlan extends Equatable {
  final PlanTier tier;
  final PlanLimits limits;
  final int storedBytes;

  /// Linked devices.
  final int devices;

  /// UUIDs of the linked devices that cannot back up: more linked devices than the plan allows (a paid plan ended).
  final List<String> pausedDevices;

  /// More stored than the plan allows (a paid plan ended): nothing new can be uploaded.
  final bool readOnly;

  /// Null for a user who never subscribed.
  final PlanSubscription? subscription;

  /// Sent to the store with each purchase, so the server knows the purchase is of this account. Null while buying is
  /// off in the server.
  final String? billingAccountId;

  const UserPlan({
    required this.tier,
    required this.limits,
    required this.storedBytes,
    required this.devices,
    required this.pausedDevices,
    required this.readOnly,
    required this.subscription,
    this.billingAccountId,
  });

  bool isPaused(String deviceUuid) => pausedDevices.contains(deviceUuid);

  /// Whether a video of [plainBytes] can be uploaded with this plan.
  bool allowsVideo(int plainBytes) => plainBytes <= limits.maxVideoBytes;

  @override
  List<Object?> get props => [tier, limits, storedBytes, devices, pausedDevices, readOnly, subscription, billingAccountId];
}
