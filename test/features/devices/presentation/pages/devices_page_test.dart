import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_state.dart';
import 'package:photo_manager_app/features/devices/presentation/pages/devices_page.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/device_card.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/devices_empty_state.dart';
import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockDeviceBloc extends MockBloc<DeviceEvent, DeviceState>
    implements DeviceBloc {}

class FakeLoadDevices extends Fake implements LoadDevices {}

class FakeRefreshDevices extends Fake implements RefreshDevices {}

void main() {
  late MockDeviceBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeLoadDevices());
    registerFallbackValue(FakeRefreshDevices());
  });

  setUp(() {
    mockBloc = MockDeviceBloc();
  });

  final testDevices = TestDeviceEntities.deviceList;

  Widget buildTestWidget(DeviceState state) {
    when(() => mockBloc.state).thenReturn(state);
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(state));

    return makeTestableWidget(
      BlocProvider<DeviceBloc>.value(
        value: mockBloc,
        child: const DevicesPage(),
      ),
    );
  }

  group('DevicesPage', () {
    testWidgets('should display AppBar with title', (tester) async {
      when(() => mockBloc.state).thenReturn(DeviceLoading());
      when(() => mockBloc.stream)
          .thenAnswer((_) => Stream.value(DeviceLoading()));

      await tester.pumpWidget(buildTestWidget(DeviceLoading()));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading indicator when state is DeviceLoading',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(DeviceLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error display when state is DeviceError',
        (tester) async {
      final errorState = DeviceError(NetworkFailure());

      await tester.pumpWidget(buildTestWidget(errorState));
      await tester.pumpAndSettle();

      // Check for error display by looking for retry button
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should trigger LoadDevices on error retry', (tester) async {
      final errorState = DeviceError(NetworkFailure());

      await tester.pumpWidget(buildTestWidget(errorState));
      await tester.pumpAndSettle();

      final retryButton = find.text('Try again');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(any<LoadDevices>())).called(1);
    });

    testWidgets('should display empty state when loaded with no devices',
        (tester) async {
      final emptyState = DeviceLoaded([]);

      await tester.pumpWidget(buildTestWidget(emptyState));
      await tester.pumpAndSettle();

      expect(find.byType(DevicesEmptyState), findsOneWidget);
    });

    testWidgets('should display list of devices when loaded with devices',
        (tester) async {
      final loadedState = DeviceLoaded(testDevices);

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(DeviceCard), findsNWidgets(testDevices.length));
    });

    testWidgets('should display RefreshIndicator when devices are loaded',
        (tester) async {
      final loadedState = DeviceLoaded(testDevices);

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should trigger RefreshDevices on pull to refresh',
        (tester) async {
      final loadedState = DeviceLoaded(testDevices);

      await tester.pumpWidget(buildTestWidget(loadedState));
      await tester.pumpAndSettle();

      // Simulate pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(any<RefreshDevices>())).called(1);
    });

    testWidgets(
        'should show devices and highlight device performing action when state is DeviceActionInProgress',
        (tester) async {
      final actionState = DeviceActionInProgress(
        devices: testDevices,
        actionDeviceId: testDevices[0].id,
      );

      await tester.pumpWidget(buildTestWidget(actionState));
      await tester.pump();

      expect(find.byType(DeviceCard), findsNWidgets(testDevices.length));
      // Verify action indicator is shown for the first device
      final deviceCard = tester.widget<DeviceCard>(find.byType(DeviceCard).first);
      expect(deviceCard.isPerformingAction, true);
    });

    testWidgets('should show success snackbar when state is DeviceActionSuccess',
        (tester) async {
      final successState = DeviceActionSuccess(testDevices);

      when(() => mockBloc.state).thenReturn(successState);
      when(() => mockBloc.stream)
          .thenAnswer((_) => Stream.value(successState));

      await tester.pumpWidget(buildTestWidget(successState));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show error snackbar when state is DeviceError',
        (tester) async {
      final errorState = DeviceError(NetworkFailure());

      when(() => mockBloc.state).thenReturn(errorState);
      when(() => mockBloc.stream).thenAnswer((_) => Stream.value(errorState));

      await tester.pumpWidget(buildTestWidget(errorState));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should return empty widget for unhandled states',
        (tester) async {
      final initialState = DeviceInitial();

      await tester.pumpWidget(buildTestWidget(initialState));
      await tester.pumpAndSettle();

      // For unhandled states, the page should render without crashing
      // The builder returns const SizedBox.shrink() for unhandled states
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
