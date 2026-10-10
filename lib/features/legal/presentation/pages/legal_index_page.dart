import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/repositories/legal_document_repository.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// The information pages and the legal texts, readable without a session (login, register and Profile).
class LegalIndexPage extends StatelessWidget {
  final LegalDocumentRepository? repository;

  const LegalIndexPage({super.key, this.repository});

  static const Map<LegalDocumentType, IconData> _icons = {
    LegalDocumentType.protection: Symbols.shield_lock_rounded,
    LegalDocumentType.forgotPassword: Symbols.lock_reset_rounded,
    LegalDocumentType.recoveryWords: Symbols.key_rounded,
    LegalDocumentType.terms: Symbols.gavel_rounded,
    LegalDocumentType.privacy: Symbols.privacy_tip_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final documents = repository ?? sl<LegalDocumentRepository>();
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: SecondaryTopBar(onBack: () => _back(context), backgroundColor: palette.surface),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.legalInfoTitle,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
                const SizedBox(height: 8),
                Text(l10n.legalInfoSubtitle, style: TextStyle(fontSize: 15, color: palette.ink2)),
                const SizedBox(height: 20),
              ],
            ),
          ),
          ListRowGroup(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final type in LegalDocumentType.values)
                ListRow(
                  key: ValueKey('legal-${type.slug}'),
                  icon: _icons[type],
                  title: documents.document(type, languageCode).title,
                  onTap: () => context.push(RoutePaths.legalDocumentOf(type.slug)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.login);
    }
  }
}
