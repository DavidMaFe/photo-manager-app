import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/auth_title.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/step_indicator.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Shared layout of the three password reset steps.
class PasswordResetLayout extends StatelessWidget {
  static const int totalSteps = 3;

  final int step;
  final IconData icon;
  final String title;
  final String? description;
  final InlineSpan? descriptionSpan;
  final Widget child;
  final String primaryLabel;

  /// `null` disables the primary button.
  final VoidCallback? onPrimary;
  final bool isLoading;
  final VoidCallback onBack;

  const PasswordResetLayout({
    super.key,
    required this.step,
    required this.icon,
    required this.title,
    this.description,
    this.descriptionSpan,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onBack,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final stepLabel = l10n.stepOf(step, totalSteps);

    return Scaffold(
      backgroundColor: p.surface,
      appBar: SecondaryTopBar(
        onBack: onBack,
        backgroundColor: p.surface,
        actions: [
          StepIndicator(current: step, total: totalSteps, semanticLabel: stepLabel),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: p.accentSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(icon, size: 28, color: p.accentInk),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      stepLabel,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2),
                    ),
                    const SizedBox(height: 6),
                    AuthTitle(title: title, subtitle: description, subtitleSpan: descriptionSpan),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: AppButton.primary(
                label: primaryLabel,
                onPressed: onPrimary,
                loading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
