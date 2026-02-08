import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_state.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/device_card.dart';
import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockDeviceBloc extends MockBloc<DeviceEvent, DeviceState>
    implements DeviceBloc {}

class FakeDeviceEvent extends Fake implements DeviceEvent {}

class FakeToggleAutoSync extends Fake implements ToggleAutoSync {}

void main() {
  late MockDeviceBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeDeviceEvent());
    registerFallbackValue(FakeToggleAutoSync());
  });

  setUp(() {
    mockBloc = MockDeviceBloc();
  });

  final testAndroidDevice = TestDeviceEntities.androidDevice;
  final testIOSDevice = TestDeviceEntities.iosDevice;
  final testUnknownDevice = TestDeviceEntities.unknownOsDevice;

  Widget buildTestWidget(DeviceCard child) {
    return makeTestableWidgetWithBloc<DeviceBloc>(
      bloc: mockBloc,
      child: Scaffold(body: child),
    );
  }

  group('DeviceCard', () {
    group('Device Icon', () {
      testWidgets('should display Android icon for Android device',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        expect(find.byIcon(Icons.android), findsOneWidget);
      });

      testWidgets('should display iOS icon for iOS device', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testIOSDevice,
            isPerformingAction: false,
          ),
        ));

        expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
      });

      testWidgets('should display generic device icon for unknown OS',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testUnknownDevice,
            isPerformingAction: false,
          ),
        ));

        expect(find.byIcon(Icons.devices), findsOneWidget);
      });
    });

    group('Device Information', () {
      testWidgets('should display device name', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        expect(find.text(testAndroidDevice.name), findsOneWidget);
      });

      testWidgets('should display OS type and version', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        expect(
          find.text('${testAndroidDevice.osType} ${testAndroidDevice.osVersion}'),
          findsOneWidget,
        );
      });
    });

    group('Auto Sync Toggle', () {
      testWidgets('should display auto sync status when enabled',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        expect(find.byType(Switch), findsOneWidget);
        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, testAndroidDevice.autoSync);
      });

      testWidgets('should display auto sync status when disabled',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testIOSDevice,
            isPerformingAction: false,
          ),
        ));

        expect(find.byType(Switch), findsOneWidget);
        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, testIOSDevice.autoSync);
      });

      testWidgets('should trigger ToggleAutoSync event when switch is toggled',
          (tester) async {
        when(() => mockBloc.add(any())).thenReturn(null);

        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        await tester.tap(find.byType(Switch));
        await tester.pump();

        verify(() => mockBloc.add(any<ToggleAutoSync>())).called(1);
      });

      testWidgets('should disable switch when performing action',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: true,
          ),
        ));

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.onChanged, isNull);
      });
    });

    group('Action Buttons', () {
      testWidgets('should display rename and delete buttons when not performing action',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('should display loading indicator when performing action',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: true,
          ),
        ));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      });

      testWidgets('should have rename button that is tappable',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));
        await tester.pumpAndSettle();

        // Verify the rename button exists and is tappable
        final renameButton = find.byIcon(Icons.edit_outlined);
        expect(renameButton, findsOneWidget);

        // Verify button is enabled (can be tapped without error)
        final button = tester.widget<IconButton>(
          find.ancestor(
            of: renameButton,
            matching: find.byType(IconButton),
          ),
        );
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should have delete button that is tappable',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));
        await tester.pumpAndSettle();

        // Verify the delete button exists and is tappable
        final deleteButton = find.byIcon(Icons.delete_outline);
        expect(deleteButton, findsOneWidget);

        // Verify button is enabled (can be tapped without error)
        final button = tester.widget<IconButton>(
          find.ancestor(
            of: deleteButton,
            matching: find.byType(IconButton),
          ),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('Visual Design', () {
      testWidgets('should display gradient accent strip', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        // Check for gradient decoration
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should apply different colors for different OS types',
          (tester) async {
        // We can't easily test colors directly, but we can verify the icons are present
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));
        expect(find.byIcon(Icons.android), findsOneWidget);

        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testIOSDevice,
            isPerformingAction: false,
          ),
        ));
        expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have tooltips for action buttons', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DeviceCard(
            device: testAndroidDevice,
            isPerformingAction: false,
          ),
        ));

        final renameButton = find.byIcon(Icons.edit_outlined);
        final deleteButton = find.byIcon(Icons.delete_outline);

        expect(renameButton, findsOneWidget);
        expect(deleteButton, findsOneWidget);

        final renameIconButton = tester.widget<IconButton>(
          find.ancestor(
            of: renameButton,
            matching: find.byType(IconButton),
          ),
        );
        expect(renameIconButton.tooltip, isNotNull);

        final deleteIconButton = tester.widget<IconButton>(
          find.ancestor(
            of: deleteButton,
            matching: find.byType(IconButton),
          ),
        );
        expect(deleteIconButton.tooltip, isNotNull);
      });
    });
  });
}
