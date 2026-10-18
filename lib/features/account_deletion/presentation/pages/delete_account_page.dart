import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/core/widgets/section_label.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/bloc/account_deletion_summary_cubit.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/widgets/delete_account_header.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/widgets/save_everything_row.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// First step of the account deletion: what is deleted, and how to save the photos on this phone first.
class DeleteAccountPage extends StatelessWidget {
  /// Replaces [SaveEverythingRow] in tests.
  final Widget? saveEverythingRow;

  const DeleteAccountPage({super.key, this.saveEverythingRow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: DeleteAccountTopBar(step: 1, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: DeleteAccountHeading(
                      step: 1,
                      showIcon: true,
                      title: l10n.deleteAccountTitle,
                      subtitle: Text(l10n.deleteAccountSubtitle),
                    ),
                  ),
                  SectionLabel(l10n.deleteAccountWhatIsDeleted),
                  BlocBuilder<AccountDeletionSummaryCubit, AccountDeletionSummaryState>(
                    builder: (context, state) => switch (state) {
                      AccountDeletionSummaryLoaded(:final summary) => _WhatIsDeleted(summary: summary),
                      AccountDeletionSummaryError(:final failure) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ErrorDisplay(
                            failure: failure,
                            onRetry: () => context.read<AccountDeletionSummaryCubit>().load(),
                          ),
                        ),
                      _ => const Padding(
                          key: ValueKey('delete-account-summary-loading'),
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    },
                  ),
                  SectionLabel(l10n.deleteAccountTakePhotos),
                  ListRowGroup(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    children: [saveEverythingRow ?? const SaveEverythingRow()],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<AccountDeletionSummaryCubit, AccountDeletionSummaryState>(
                    builder: (context, state) => AppButton.danger(
                      key: const ValueKey('delete-account-continue'),
                      label: l10n.deleteAccountContinue,
                      onPressed: state is AccountDeletionSummaryLoaded
                          ? () => context.pushNamed(RouteNames.deleteAccountConfirm)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppButton.text(
                    key: const ValueKey('delete-account-keep'),
                    label: l10n.deleteAccountKeep,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatIsDeleted extends StatelessWidget {
  final AccountDeletionSummary summary;

  const _WhatIsDeleted({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final size = FileSizeFormatter.format(summary.storedBytes, locale: Localizations.localeOf(context).toLanguageTag());
    // Deleting the account cancels the renewal in the store
    final renews = context.select<PlanCubit, bool>((cubit) => cubit.state.plan?.subscription?.renews ?? false);
    return ListRowGroup(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ListRow(
          icon: Symbols.photo_library_rounded,
          iconColor: p.danger,
          title: l10n.deleteAccountFiles(summary.files),
          subtitle: l10n.deleteAccountFilesDetail(size),
        ),
        ListRow(
          icon: Symbols.photo_album_rounded,
          iconColor: p.danger,
          title: l10n.deleteAccountAlbums(summary.albums),
          subtitle: l10n.deleteAccountAlbumsDetail,
        ),
        ListRow(
          icon: Symbols.devices_rounded,
          iconColor: p.danger,
          title: l10n.deleteAccountDevices(summary.devices),
          subtitle: l10n.deleteAccountDevicesDetail,
        ),
        if (renews)
          ListRow(
            icon: Symbols.credit_card_off_rounded,
            iconColor: p.danger,
            title: l10n.deleteAccountSubscription,
            subtitle: l10n.deleteAccountSubscriptionDetail,
          ),
        ListRow(
          icon: Symbols.smartphone_rounded,
          iconColor: p.safe,
          title: l10n.deleteAccountPhoneSafe,
          subtitle: l10n.deleteAccountPhoneSafeDetail,
        ),
      ],
    );
  }
}
