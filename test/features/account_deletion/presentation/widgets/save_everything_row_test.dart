import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/widgets/save_everything_row.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';

import '../../../../helpers/downloads_test_providers.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pumpRow(WidgetTester tester, OnDevicePresenceState presence,
      {DeviceStorage? storage, void Function()? onOpen}) async {
    final providers = DownloadsTestProviders(presenceState: presence);
    await tester.pumpWidget(makeTestableWidget(
      MultiBlocProvider(
        providers: providers.providers,
        child: Scaffold(
          body: SaveEverythingRow(
            loadStorage: () async => storage,
            onOpen: (_) => onOpen?.call(),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  group('SaveEverythingRow', () {
    testWidgets('should show what is missing and the free space, and open the download', (tester) async {
      var opened = 0;
      final providers = DownloadsTestProviders(
          presenceState: const OnDevicePresenceState(known: true, missing: {'1', '2'}, missingBytes: 2048));
      await tester.pumpWidget(makeTestableWidget(
        MultiBlocProvider(
          providers: providers.providers,
          child: Scaffold(
            body: SaveEverythingRow(
              loadStorage: () async => const DeviceStorage(freeBytes: 5 * 1024 * 1024 * 1024, totalBytes: 1),
              onOpen: (_) => opened++,
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Save everything on this phone'), findsOneWidget);
      expect(find.text('2 to download · you have 5.0 GB free'), findsOneWidget);

      await tester.tap(find.text('Save everything on this phone'));
      expect(opened, 1);
    });

    testWidgets('should show the size to download where the free space is not known', (tester) async {
      await pumpRow(tester, const OnDevicePresenceState(known: true, missing: {'1'}, missingBytes: 2048));

      expect(find.text('1 to download · 2 KB'), findsOneWidget);
    });

    testWidgets('should say that everything is on this phone and not open the download', (tester) async {
      var opened = 0;
      await pumpRow(tester, const OnDevicePresenceState(known: true), onOpen: () => opened++);

      expect(find.text('Everything is already on this phone'), findsOneWidget);
      await tester.tap(find.text('Save everything on this phone'));
      expect(opened, 0);
    });

    testWidgets('should show no detail while what is missing is not known', (tester) async {
      await pumpRow(tester, const OnDevicePresenceState());

      expect(find.textContaining('to download'), findsNothing);
      expect(find.text('Everything is already on this phone'), findsNothing);
    });
  });
}
