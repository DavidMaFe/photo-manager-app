import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_state.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/device_card.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/dialogs/rename_device_dialog.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockDeviceBloc extends MockBloc<DeviceEvent, DeviceState> implements DeviceBloc {}

class FakeDeviceEvent extends Fake implements DeviceEvent {}

void main() {
  late MockDeviceBloc bloc;

  setUpAll(() => registerFallbackValue(FakeDeviceEvent()));

  setUp(() {
    bloc = MockDeviceBloc();
    when(() => bloc.state).thenReturn(DeviceLoaded(TestDeviceEntities.deviceList));
  });

  Future<void> pump(WidgetTester tester, Device device, {bool busy = false, bool current = false}) {
    return tester.pumpWidget(makeTestableWidget(BlocProvider<DeviceBloc>.value(
      value: bloc,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: DeviceCard(device: device, isPerformingAction: busy, isCurrentDevice: current),
        ),
      ),
    )));
  }

  Container iconBox(WidgetTester tester) => tester.widget<Container>(
        find.ancestor(of: find.byType(Icon).first, matching: find.byType(Container)).first,
      );

  group('DeviceCard', () {
    // ==================== CONTENT TESTS ====================

    testWidgets('should show the name and OS version', (tester) async {
      // Arrange & Act
      await pump(tester, TestDeviceEntities.androidDevice);

      // Assert
      expect(find.text('Samsung Galaxy S21'), findsOneWidget);
      expect(find.textContaining('Android '), findsOneWidget);
    });

    testWidgets('should show the last backup next to the OS', (tester) async {
      // Arrange
      final now = DateTime.now();
      final device = TestDeviceEntities.androidDevice.copyWith(
        lastSyncAt: DateTime(now.year, now.month, now.day, 3),
      );

      // Act
      await pump(tester, device);

      // Assert
      expect(find.text('Android ${device.osVersion} · Last backup today, 03:00'), findsOneWidget);
    });

    testWidgets('should show only the OS when the device never backed up', (tester) async {
      // Arrange & Act
      await pump(tester, TestDeviceEntities.androidDevice);

      // Assert
      expect(find.text('Android ${TestDeviceEntities.androidDevice.osVersion}'), findsOneWidget);
      expect(find.textContaining('Last backup'), findsNothing);
    });

    testWidgets('should use the phone icon per platform', (tester) async {
      await pump(tester, TestDeviceEntities.iosDevice);
      expect(find.byIcon(Symbols.phone_iphone_rounded), findsOneWidget);

      await pump(tester, TestDeviceEntities.deviceWithLowercaseOs);
      expect(find.byIcon(Symbols.smartphone_rounded), findsOneWidget);

      await pump(tester, TestDeviceEntities.unknownOsDevice);
      expect(find.byIcon(Symbols.devices_rounded), findsOneWidget);
    });

    testWidgets('should tag and highlight the current device', (tester) async {
      // Arrange & Act
      await pump(tester, TestDeviceEntities.androidDevice, current: true);

      // Assert
      expect(find.text('This phone'), findsOneWidget);
      expect((iconBox(tester).decoration as BoxDecoration).color, AppPalette.light.accentSoft);
    });

    testWidgets('should not tag other devices', (tester) async {
      // Arrange & Act
      await pump(tester, TestDeviceEntities.androidDevice);

      // Assert
      expect(find.text('This phone'), findsNothing);
      expect((iconBox(tester).decoration as BoxDecoration).color, AppPalette.light.surface2);
    });

    testWidgets('should not draw the old gradient side strip', (tester) async {
      // Arrange & Act
      await pump(tester, TestDeviceEntities.androidDevice);

      // Assert
      final gradients = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).gradient != null);
      expect(gradients, isEmpty);
    });

    // ==================== AUTO BACKUP TESTS ====================

    testWidgets('should reflect and toggle automatic backup', (tester) async {
      // Arrange
      await pump(tester, TestDeviceEntities.iosDevice);
      expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isFalse);

      // Act
      await tester.tap(find.byType(Switch));

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(
        event,
        isA<ToggleAutoSync>()
            .having((e) => e.deviceId, 'deviceId', TestDeviceEntities.iosDevice.id)
            .having((e) => e.enabled, 'enabled', true),
      );
    });

    testWidgets('should show progress instead of the switch while busy', (tester) async {
      // Arrange & Act
      await pump(tester, TestDeviceEntities.androidDevice, busy: true);

      // Assert
      expect(find.byType(AppSwitch), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    });

    // ==================== MENU TESTS ====================

    testWidgets('should open rename from the menu and dispatch the new name', (tester) async {
      // Arrange
      await pump(tester, TestDeviceEntities.androidDevice);
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      expect(find.byType(RenameDeviceDialog), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Work phone');
      await tester.tap(find.descendant(of: find.byType(RenameDeviceDialog), matching: find.text('Rename')));
      await tester.pumpAndSettle();

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<RenameDevice>().having((e) => e.newName, 'newName', 'Work phone'));
    });

    testWidgets('should confirm before unlinking', (tester) async {
      // Arrange
      await pump(tester, TestDeviceEntities.androidDevice);
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Unlink'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.widgetWithText(AppButton, 'Unlink')));
      await tester.pumpAndSettle();

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<UnlinkDevice>().having((e) => e.deviceId, 'deviceId', TestDeviceEntities.androidDevice.id));
    });

    testWidgets('should validate the device name', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: RenameDeviceDialog(currentName: 'Phone', onConfirm: (_) {}),
      )));
      final field = tester.widget<TextFormField>(find.byType(TextFormField));

      // Assert
      expect(field.validator!(' '), 'Device name is required');
      expect(field.validator!('a' * 51), isNotNull);
      expect(field.validator!('Phone'), isNull);
    });
  });
}
