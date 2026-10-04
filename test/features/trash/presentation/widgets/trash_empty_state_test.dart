import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_empty_state.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('TrashEmptyState', () {
    testWidgets('should use the shared empty state with the trash texts', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: TrashEmptyState())));

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Trash is empty'), findsOneWidget);
    });
  });
}
