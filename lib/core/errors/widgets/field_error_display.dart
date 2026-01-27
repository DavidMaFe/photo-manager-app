import 'package:flutter/material.dart';

/// Standalone widget for displaying field-level validation errors
///
/// Ideal for inline display in forms, below input fields, or in validation summaries.
///
/// Features:
/// - Compact design optimized for form fields
/// - Color-coded by severity
/// - Optional field name display
/// - Supports single field or multiple field errors
///
/// Usage:
/// ```dart
/// // Single field error
/// FieldErrorDisplay(
///   fieldName: 'email',
///   errorMessage: 'Email is required',
/// )
///
/// // Multiple field errors
/// FieldErrorDisplay.multiple(
///   fieldErrors: {
///     'email': 'Email is required',
///     'password': 'Password must be at least 8 characters',
///   },
/// )
/// ```
class FieldErrorDisplay extends StatelessWidget {
  final String? fieldName;
  final String? errorMessage;
  final Map<String, String>? fieldErrors;
  final Color? color;
  final EdgeInsets? padding;
  final bool showFieldNames;

  /// Creates a single field error display
  const FieldErrorDisplay({
    super.key,
    required this.fieldName,
    required this.errorMessage,
    this.color,
    this.padding,
    this.showFieldNames = true,
  }) : fieldErrors = null;

  /// Creates a multiple field error display
  const FieldErrorDisplay.multiple({
    super.key,
    required this.fieldErrors,
    this.color,
    this.padding,
    this.showFieldNames = true,
  })  : fieldName = null,
        errorMessage = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = color ?? (isDark ? Colors.red.shade300 : Colors.red.shade700);

    // Multiple field errors
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: errorColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: fieldErrors!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: errorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: showFieldNames
                        ? RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: '${entry.key}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: entry.value),
                              ],
                            ),
                          )
                        : Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    // Single field error
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: errorColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: errorColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: showFieldNames && fieldName != null
                  ? RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: '$fieldName: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: errorMessage),
                        ],
                      ),
                    )
                  : Text(
                      errorMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    // No errors to display
    return const SizedBox.shrink();
  }
}
