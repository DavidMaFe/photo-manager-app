import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Mandatory acceptance of the terms of use and the privacy policy, with links to read them. Part of a [Form]: it
/// does not validate until it is ticked.
class LegalAcceptanceCheckbox extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  const LegalAcceptanceCheckbox({super.key, this.enabled = true, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final textStyle = TextStyle(fontSize: 13, color: palette.ink2);

    return FormField<bool>(
      initialValue: false,
      validator: (value) => value == true ? null : l10n.legalAcceptRequired,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                key: const ValueKey('legal-accept-checkbox'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                value: field.value ?? false,
                onChanged: enabled
                    ? (value) {
                        field.didChange(value ?? false);
                        onChanged?.call(value ?? false);
                      }
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${l10n.legalAcceptPrefix} ', style: textStyle),
                      _Link(
                        key: const ValueKey('legal-terms-link'),
                        label: l10n.legalTermsLink,
                        document: LegalDocumentType.terms,
                      ),
                      Text(' ${l10n.legalAcceptMiddle} ', style: textStyle),
                      _Link(
                        key: const ValueKey('legal-privacy-link'),
                        label: l10n.legalPrivacyLink,
                        document: LegalDocumentType.privacy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(field.errorText!, style: TextStyle(fontSize: 12, color: palette.dangerInk)),
            ),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  final String label;
  final LegalDocumentType document;

  const _Link({super.key, required this.label, required this.document});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RoutePaths.legalDocumentOf(document.slug)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.palette.accent,
              decoration: TextDecoration.underline,
            )),
      ),
    );
  }
}
