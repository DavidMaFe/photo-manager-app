/// Plans of the app (ROADMAP-subscriptions.md in the backend). The order is from the smallest to the biggest.
enum PlanTier {
  free('FREE'),
  plus100('PLUS_100'),
  plus250('PLUS_250'),
  plus1tb('PLUS_1TB');

  /// Name in the API.
  final String apiName;

  const PlanTier(this.apiName);

  bool get isPaid => this != PlanTier.free;

  /// The plan named [apiName], or the free plan for an unknown one.
  static PlanTier fromApi(String? apiName) =>
      values.firstWhere((tier) => tier.apiName == apiName, orElse: () => PlanTier.free);
}
