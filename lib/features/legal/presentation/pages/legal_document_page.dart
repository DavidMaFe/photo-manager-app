import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/repositories/legal_document_repository.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_document_view.dart';

/// One information page or legal text, in the language of the app.
class LegalDocumentPage extends StatelessWidget {
  final LegalDocumentType type;
  final LegalDocumentRepository? repository;

  const LegalDocumentPage({super.key, required this.type, this.repository});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final document = (repository ?? sl<LegalDocumentRepository>())
        .document(type, Localizations.localeOf(context).languageCode);

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: SecondaryTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go(RoutePaths.legal),
        backgroundColor: palette.surface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.paddingOf(context).bottom + 24),
        child: LegalDocumentView(document: document),
      ),
    );
  }
}
