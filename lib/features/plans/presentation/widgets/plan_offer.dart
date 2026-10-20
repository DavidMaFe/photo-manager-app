import 'package:photo_manager_app/features/plans/domain/entities/plan_limits.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';

/// A plan as the plans page shows it. The prices are the ones of the launch (euros, VAT included); with Google Play
/// Billing (Phase 4) the page shows the prices of the store in the currency of the user.
class PlanOffer {
  final PlanTier tier;
  final PlanLimits limits;

  /// Null for the free plan.
  final double? monthlyPrice;
  final double? annualPrice;

  const PlanOffer({required this.tier, required this.limits, this.monthlyPrice, this.annualPrice});

  static const int _mib = 1024 * 1024;
  static const int _gib = 1024 * _mib;

  /// The free plan of a new account (5 GB); the accounts from before the plans keep 10 GB, as their plan says.
  static const List<PlanOffer> catalog = [
    PlanOffer(
      tier: PlanTier.free,
      limits: PlanLimits(storageBytes: 5 * _gib, maxDevices: 2, maxVideoBytes: 100 * _mib, dailyBackup: false),
    ),
    PlanOffer(
      tier: PlanTier.plus100,
      limits: PlanLimits(storageBytes: 100 * _gib, maxDevices: 3, maxVideoBytes: 2 * _gib, dailyBackup: true),
      monthlyPrice: 1.99,
      annualPrice: 19.99,
    ),
    PlanOffer(
      tier: PlanTier.plus250,
      limits: PlanLimits(storageBytes: 250 * _gib, maxDevices: 5, maxVideoBytes: 2 * _gib, dailyBackup: true),
      monthlyPrice: 3.99,
      annualPrice: 39.99,
    ),
    PlanOffer(
      tier: PlanTier.plus1tb,
      limits: PlanLimits(storageBytes: 1024 * _gib, maxDevices: 10, maxVideoBytes: 2 * _gib, dailyBackup: true),
      monthlyPrice: 9.99,
      annualPrice: 99.99,
    ),
  ];
}
