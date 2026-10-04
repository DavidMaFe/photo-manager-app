import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  group('FailureMessageHelper', () {
    Future<(String, String)> resolve(WidgetTester tester, Failure failure, Locale locale) async {
      late String title;
      late String message;
      await tester.pumpWidget(makeTestableWidget(
        Builder(builder: (context) {
          title = FailureMessageHelper.getTitle(context, failure);
          message = FailureMessageHelper.getMessage(context, failure);
          return const SizedBox();
        }),
        locale: locale,
      ));
      return (title, message);
    }

    group('ConcurrencyFailure', () {
      testWidgets('should explain that a backup is already running in Spanish', (tester) async {
        // Arrange
        const failure = ConcurrencyFailure();

        // Act
        final (title, message) = await resolve(tester, failure, const Locale('es'));

        // Assert
        expect(title, 'Copia en curso');
        expect(message, 'Ya se está haciendo una copia. Espera a que termine e inténtalo de nuevo.');
      });

      testWidgets('should explain that a backup is already running in English', (tester) async {
        // Arrange
        const failure = ConcurrencyFailure();

        // Act
        final (title, message) = await resolve(tester, failure, const Locale('en'));

        // Assert
        expect(title, 'Backup in progress');
        expect(message, 'A backup is already running. Wait for it to finish and try again.');
      });
    });

    testWidgets('should keep the generic message for unknown failures', (tester) async {
      // Arrange
      const failure = UnknownFailure();

      // Act
      final (_, message) = await resolve(tester, failure, const Locale('es'));

      // Assert
      expect(message, 'Ocurrió un error inesperado. Por favor inténtalo más tarde.');
    });
  });
}
