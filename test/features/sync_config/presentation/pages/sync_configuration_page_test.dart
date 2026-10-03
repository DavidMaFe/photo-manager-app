import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/segmented_control.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';
import 'package:photo_manager_app/features/sync_config/presentation/pages/sync_configuration_page.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/day_of_week_picker_widget.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockSyncConfigBloc extends Mock implements SyncConfigBloc {}

class FakeSyncConfigEvent extends Fake implements SyncConfigEvent {}

void main() {
  late MockSyncConfigBloc bloc;

  setUpAll(() => registerFallbackValue(FakeSyncConfigEvent()));

  setUp(() {
    bloc = MockSyncConfigBloc();
  });

  /// Pumps the view with [initial] and then [states] in order.
  Future<void> pump(WidgetTester tester, SyncConfig initial, {List<SyncConfigState> states = const []}) async {
    setUpCustomScreenSize(tester, 390, 1600);
    when(() => bloc.state).thenReturn(SyncConfigLoaded(initial));
    when(() => bloc.stream).thenAnswer((_) => Stream.fromIterable(states));
    await tester.pumpWidget(makeTestableWidgetWithBloc<SyncConfigBloc>(
      bloc: bloc,
      child: const SyncConfigurationView(showDiagnostics: false),
    ));
    await tester.pump();
  }

  AppButton saveButton(WidgetTester tester) => tester.widget<AppButton>(find.widgetWithText(AppButton, 'Save changes'));

  group('SyncConfigurationView', () {
    // ==================== LAYOUT TESTS ====================

    testWidgets('should show the master switch and the three sections', (tester) async {
      // Arrange & Act
      await pump(tester, TestSyncConfigs.dailySync);

      // Assert
      expect(find.text('Backup settings'), findsOneWidget);
      expect(find.text('Automatic backup'), findsOneWidget);
      expect(find.text('WHEN'), findsOneWidget);
      expect(find.text('CONDITIONS'), findsOneWidget);
      expect(find.text('ALERTS'), findsOneWidget);
      expect(find.byType(SegmentedControl<SyncFrequency>), findsOneWidget);
      expect(find.text('02:00'), findsOneWidget);
      expect(find.textContaining('Next backup:'), findsOneWidget);
    });

    testWidgets('should show the weekday boxes only for weekly backups', (tester) async {
      // Arrange & Act
      await pump(tester, TestSyncConfigs.weeklySync);

      // Assert
      expect(find.byType(DayOfWeekPickerWidget), findsOneWidget);
      expect(find.bySemanticsLabel('Monday'), findsOneWidget);
    });

    testWidgets('should not use unthemed Material cards', (tester) async {
      // Arrange & Act
      await pump(tester, TestSyncConfigs.dailySync);

      // Assert
      expect(find.byType(Card), findsNothing);
      expect(find.byType(RadioListTile), findsNothing);
      expect(find.byType(FilterChip), findsNothing);
    });

    // ==================== DISABLED STATE TESTS ====================

    testWidgets('should dim and lock the options while automatic backup is off', (tester) async {
      // Arrange & Act
      await pump(tester, TestSyncConfigs.disabled);

      // Assert
      final dim = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first);
      expect(dim.opacity, 0.5);
      expect(find.textContaining('Next backup:'), findsNothing);
    });

    // ==================== INTERACTION TESTS ====================

    testWidgets('should dispatch the selected frequency', (tester) async {
      // Arrange
      await pump(tester, TestSyncConfigs.dailySync);

      // Act
      await tester.tap(find.text('Once a week'));

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<UpdateSyncFrequency>().having((e) => e.frequency, 'frequency', SyncFrequency.weekly));
    });

    testWidgets('should dispatch the alert switches', (tester) async {
      // Arrange
      await pump(tester, TestSyncConfigs.dailySync);

      // Act
      await tester.tap(find.bySemanticsLabel('When it finishes'));

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<ToggleNotifyOnSuccess>().having((e) => e.enabled, 'enabled', true));
    });

    // ==================== SAVE TESTS ====================

    testWidgets('should disable save without changes', (tester) async {
      // Arrange & Act
      await pump(tester, TestSyncConfigs.dailySync);

      // Assert
      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('should enable save once the config changes and save it', (tester) async {
      // Arrange
      final changed = TestSyncConfigs.dailySync.copyWith(syncHour: 5);
      await pump(tester, TestSyncConfigs.dailySync, states: [SyncConfigLoaded(changed)]);
      await tester.pump();

      // Act
      await tester.tap(find.widgetWithText(AppButton, 'Save changes'));

      // Assert
      verify(() => bloc.add(any(that: isA<SaveSyncConfig>()))).called(1);
    });
  });
}
