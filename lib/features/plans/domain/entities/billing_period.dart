/// How often a plan is paid: the base plans of each product in the store.
enum BillingPeriod {
  monthly('monthly'),
  annual('annual');

  /// Base plan in Google Play.
  final String basePlanId;

  const BillingPeriod(this.basePlanId);

  static BillingPeriod? fromBasePlan(String? basePlanId) =>
      values.where((period) => period.basePlanId == basePlanId).firstOrNull;
}
