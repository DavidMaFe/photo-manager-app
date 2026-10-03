import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/devices_empty_state.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('DevicesEmptyState', () {
    testWidgets('should use the shared empty state with the device texts', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: DevicesEmptyState())));

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No linked devices'), findsOneWidget);
    });
  });
}
