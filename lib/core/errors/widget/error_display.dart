import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../base/failures.dart';


class ErrorDisplay extends StatelessWidget {

  final Failure failure;
  final VoidCallback? onRetry;
  final String? customMessageKey;

  const ErrorDisplay({
    super.key,
    required this.failure,
    this.onRetry,
    this.customMessageKey
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final message = customMessageKey != null
        ? _getCustomMessage(l10n, customMessageKey!)
        : FailureMessageHelper.getMessage(context, failure);
    final title = FailureMessageHelper.getTitle(context, failure);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 80,
              color: Colors.red.shade400
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.tryAgain),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16
                  )
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (failure is NetworkFailure) return Icons.wifi_off;
    if (failure is ServerFailure) return Icons.cloud_off;
    if (failure is NotFoundFailure) return Icons.search_off;
    return Icons.error_outline;
  }

  String _getCustomMessage(AppLocalizations l10n, String key) {
    switch (key) {
      case 'errorNetwork':
        return l10n.errorNetwork;
      case 'errorServer':
        return l10n.errorServer;
      default:
        return l10n.errorUnknown;
    }
  }
}