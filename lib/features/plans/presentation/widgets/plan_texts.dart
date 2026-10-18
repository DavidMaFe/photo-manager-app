import 'package:intl/intl.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_limits.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Texts of the plans, shared by the profile, the plans page and the limit notices.
class PlanTexts {
  const PlanTexts._();

  static String name(PlanTier tier, AppLocalizations l10n) => switch (tier) {
        PlanTier.free => l10n.planNameFree,
        PlanTier.plus100 => l10n.planName100,
        PlanTier.plus250 => l10n.planName250,
        PlanTier.plus1tb => l10n.planName1tb,
      };

  static const int _mib = 1024 * 1024;
  static const int _gib = 1024 * _mib;
  static const int _tib = 1024 * _gib;

  /// Size of a limit of a plan: «5 GB», «100 MB», «1 TB», without decimals (the plans are whole binary units, like
  /// the quota).
  static String size(int bytes, AppLocalizations l10n) {
    final number = NumberFormat.decimalPattern(l10n.localeName);
    if (bytes > 0 && bytes % _tib == 0) return '${number.format(bytes ~/ _tib)} TB';
    if (bytes > 0 && bytes % _gib == 0) return '${number.format(bytes ~/ _gib)} GB';
    if (bytes > 0 && bytes % _mib == 0) return '${number.format(bytes ~/ _mib)} MB';
    return used(bytes, l10n);
  }

  /// Size actually used, with its decimals.
  static String used(int bytes, AppLocalizations l10n) => FileSizeFormatter.format(bytes, locale: l10n.localeName);

  /// «Free · 5 GB» for the profile.
  static String summary(PlanTier tier, PlanLimits limits, AppLocalizations l10n) =>
      l10n.planRowValue(name(tier, l10n), size(limits.storageBytes, l10n));

  /// What the subscription says now: renewal, end, payment problem or end of a past one; null without subscription.
  static String? subscriptionStatus(PlanSubscription? subscription, AppLocalizations l10n) {
    if (subscription == null) return null;
    final end = subscription.periodEnd;
    final date = end == null ? '' : DateFormat.yMMMd(l10n.localeName).format(end);
    return switch (subscription.status) {
      SubscriptionStatus.active => subscription.autoRenewing ? l10n.planRenews(date) : l10n.planEnds(date),
      SubscriptionStatus.canceled => l10n.planEnds(date),
      SubscriptionStatus.inGracePeriod || SubscriptionStatus.onHold => l10n.planPaymentIssue,
      SubscriptionStatus.paused || SubscriptionStatus.expired || SubscriptionStatus.revoked => l10n.planEnded(date),
    };
  }
}
