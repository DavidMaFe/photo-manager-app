import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/dialogs/unlink_device_dialog.dart';

import '../../../../../helpers/widget_test_helper.dart';

void main() {
  Future<bool> open(WidgetTester tester, {required bool isCurrentDevice}) async {
    var confirmed = false;
    await tester.pumpWidget(makeTestableWidget(Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => UnlinkDeviceDialog.show(
            context: context,
            deviceName: 'Tablet',
            isCurrentDevice: isCurrentDevice,
            onConfirm: () => confirmed = true,
          ),
          child: const Text('open'),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return confirmed;
  }

  group('UnlinkDeviceDialog', () {
    testWidgets('should say that unlinking the device in use logs out and asks for the code next time',
        (tester) async {
      await open(tester, isCurrentDevice: true);

      expect(find.textContaining('You will be logged out of it'), findsOneWidget);
      expect(find.textContaining('verification code'), findsOneWidget);
      expect(find.text('Unlink and log out'), findsOneWidget);
    });

    testWidgets('should name the other device it unlinks', (tester) async {
      await open(tester, isCurrentDevice: false);

      expect(find.textContaining("'Tablet'"), findsOneWidget);
      expect(find.text('Unlink and log out'), findsNothing);
    });
  });
}
