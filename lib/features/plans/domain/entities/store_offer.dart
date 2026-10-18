import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';

/// A plan as the store sells it, with its price in the currency of the user.
class StoreOffer extends Equatable {
  final PlanTier tier;
  final BillingPeriod period;

  /// Formatted by the store («1,99 €»).
  final String price;

  const StoreOffer({required this.tier, required this.period, required this.price});

  /// Product of the store of [tier] ({@code plus_100}).
  static String productIdOf(PlanTier tier) => switch (tier) {
        PlanTier.free => '',
        PlanTier.plus100 => 'plus_100',
        PlanTier.plus250 => 'plus_250',
        PlanTier.plus1tb => 'plus_1tb',
      };

  static PlanTier? tierOf(String productId) =>
      PlanTier.values.where((tier) => tier.isPaid && productIdOf(tier) == productId).firstOrNull;

  String get productId => productIdOf(tier);

  @override
  List<Object?> get props => [tier, period, price];
}
