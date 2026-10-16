import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_plan_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_state.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/share_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/widgets/download_feedback_listener.dart';
import 'package:photo_manager_app/features/downloads/presentation/widgets/download_progress_card.dart';
import 'package:photo_manager_app/features/downloads/presentation/widgets/download_sheet.dart';
import 'package:photo_manager_app/features/downloads/presentation/widgets/not_on_device_summary.dart';
import 'package:photo_manager_app/l10n/app_localizations_en.dart';

import '../../../../helpers/downloads_test_providers.dart';
import '../../../../helpers/widget_test_helper.dart';
import '../../downloads_mocks.dart';

class MockDownloadPlanCubit extends MockCubit<DownloadPlanState> implements DownloadPlanCubit {}

void main() {
  late DownloadsTestProviders downloads;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('DownloadSheet', () {
    late MockDownloadPlanCubit planCubit;
    final plan = DownloadsTestData.plan([DownloadsTestData.photo, DownloadsTestData.video], onDevice: 37);

    Future<void> pump(WidgetTester tester, DownloadPlanState state, {List<String> subalbums = const []}) {
      setUpCustomScreenSize(tester, 390, 1200);
      downloads = DownloadsTestProviders();
      planCubit = MockDownloadPlanCubit();
      when(() => planCubit.state).thenReturn(state);
      when(() => planCubit.setIncludeSubfolders(any())).thenAnswer((_) async {});
      return tester.pumpWidget(makeTestableWidgetWithBlocs(
        providers: [...downloads.providers, BlocProvider<DownloadPlanCubit>.value(value: planCubit)],
        child: Scaffold(body: SingleChildScrollView(
            child: DownloadSheet(albumName: 'Vacaciones 2024', subalbumNames: subalbums))),
      ));
    }

    testWidgets('should show what will be downloaded, what is skipped and the free space', (tester) async {
      await pump(tester, DownloadPlanLoaded(plan, includeSubfolders: true), subalbums: ['Playa', 'Montaña']);

      expect(find.text('Save to this phone'), findsOneWidget);
      expect(find.text('Vacaciones 2024 · 39 items'), findsOneWidget);
      expect(find.text('2 to download'), findsOneWidget);
      expect(find.text('37 already on this phone'), findsOneWidget);
      expect(find.text('Include subalbums'), findsOneWidget);
      expect(find.text('Playa, Montaña'), findsOneWidget);
      expect(find.text('Free space on this phone'), findsOneWidget);
      expect(find.textContaining('«Vacaciones 2024»'), findsOneWidget);
      expect(find.text('Download 2 items'), findsOneWidget);
    });

    testWidgets('should queue the plan into the album and close', (tester) async {
      await pump(tester, DownloadPlanLoaded(plan, includeSubfolders: true));

      await tester.tap(find.text('Download 2 items'));
      await settle(tester);

      final event = verify(() => downloads.progress.add(captureAny())).captured.single as DownloadRequested;
      expect(event.plan, plan);
      expect(event.album, 'Vacaciones 2024');
    });

    testWidgets('should change whether the subalbums are included', (tester) async {
      await pump(tester, DownloadPlanLoaded(plan, includeSubfolders: true), subalbums: ['Playa']);

      await tester.tap(find.byType(AppSwitch));
      await settle(tester);

      verify(() => planCubit.setIncludeSubfolders(false)).called(1);
    });

    testWidgets('should not let download when it does not fit', (tester) async {
      final full = DownloadsTestData.plan([DownloadsTestData.video], storage: DownloadsTestData.fullStorage);
      await pump(tester, DownloadPlanLoaded(full, includeSubfolders: true));

      expect(find.textContaining('It does not fit'), findsOneWidget);
      await tester.tap(find.text('Download 1 item'));
      await settle(tester);
      verifyNever(() => downloads.progress.add(any()));
    });

    testWidgets('should say when everything is already on this phone', (tester) async {
      await pump(tester, DownloadPlanLoaded(DownloadsTestData.plan([], onDevice: 3), includeSubfolders: true));

      expect(find.text('Everything is already on this phone'), findsOneWidget);
      expect(find.text('2 to download'), findsNothing);
    });

    testWidgets('should show the failure', (tester) async {
      await pump(tester, const DownloadPlanError(DeviceMediaUnsupportedFailure(), includeSubfolders: true));

      expect(find.text('This phone does not let the app save photos into its gallery.'), findsOneWidget);
    });
  });

  group('DownloadProgressCard', () {
    Future<void> pump(WidgetTester tester, DownloadProgressState state) {
      setUpCustomScreenSize(tester, 390, 800);
      downloads = DownloadsTestProviders(progressState: state);
      return tester.pumpWidget(makeTestableWidgetWithBlocs(
        providers: downloads.providers,
        child: const Scaffold(body: DownloadProgressCard()),
      ));
    }

    testWidgets('should show nothing without a download', (tester) async {
      await pump(tester, const DownloadProgressState());

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('should show the progress, the album and the time left, and cancel', (tester) async {
      await pump(tester, const DownloadProgressState(
        progress: DownloadProgress(total: 111, saved: 48, failed: 0, bytesTotal: 100, bytesSaved: 40,
            currentAlbum: 'Vacaciones 2024'),
        remaining: Duration(minutes: 2),
      ));

      expect(find.text('Saving to this phone · 48 of 111'), findsOneWidget);
      expect(find.text('Vacaciones 2024 · about 2 min left'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      verify(() => downloads.progress.add(const DownloadCancelRequested())).called(1);
    });

    testWidgets('should show the result of a finished download until it is closed', (tester) async {
      await pump(tester, const DownloadProgressState(
        progress: DownloadProgress(total: 3, saved: 2, failed: 1, bytesTotal: 3, bytesSaved: 2),
      ));

      expect(find.text('2 saved to this phone'), findsOneWidget);
      expect(find.text('1 could not be saved'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      verify(() => downloads.progress.add(const DownloadProgressDismissed())).called(1);
    });

    test('should format the time left', () {
      final l10n = AppLocalizationsEn();
      expect(DownloadProgressCard.formatRemaining(const Duration(seconds: 30), l10n), 'less than 1 min');
      expect(DownloadProgressCard.formatRemaining(const Duration(seconds: 150), l10n), '3 min');
    });
  });

  group('NotOnDeviceSummary', () {
    testWidgets('should show how many files are missing and their size', (tester) async {
      setUpCustomScreenSize(tester, 390, 800);
      downloads = DownloadsTestProviders(
          presenceState: const OnDevicePresenceState(known: true, missing: {'1', '2'}, missingBytes: 5 * 1024 * 1024));
      await tester.pumpWidget(makeTestableWidgetWithBlocs(
          providers: downloads.providers, child: const Scaffold(body: NotOnDeviceSummary())));

      expect(find.text('2 items · 5 MB'), findsOneWidget);
      expect(find.text('Download all'), findsOneWidget);
    });

    testWidgets('should show nothing when nothing is missing', (tester) async {
      downloads = DownloadsTestProviders(presenceState: const OnDevicePresenceState(known: true));
      await tester.pumpWidget(makeTestableWidgetWithBlocs(
          providers: downloads.providers, child: const Scaffold(body: NotOnDeviceSummary())));

      expect(find.text('Download all'), findsNothing);
    });
  });

  group('DownloadFeedbackListener', () {
    testWidgets('should tell when files start downloading or are already on this phone', (tester) async {
      downloads = DownloadsTestProviders();
      whenListen(
        downloads.progress,
        Stream.fromIterable(const [
          DownloadProgressState(outcome: DownloadOutcome(started: 3, requested: 4), outcomeSerial: 1),
          DownloadProgressState(outcome: DownloadOutcome(started: 0, requested: 2), outcomeSerial: 2),
        ]),
        initialState: const DownloadProgressState(),
      );
      await tester.pumpWidget(makeTestableWidgetWithBlocs(
          providers: downloads.providers,
          child: const Scaffold(body: DownloadFeedbackListener(child: SizedBox()))));
      await tester.pump();

      expect(find.text('They are all on this phone already'), findsOneWidget);
    });

    testWidgets('should show the failure of a download', (tester) async {
      downloads = DownloadsTestProviders();
      whenListen(
        downloads.progress,
        Stream.value(const DownloadProgressState(failure: NotEnoughSpaceFailure())),
        initialState: const DownloadProgressState(),
      );
      await tester.pumpWidget(makeTestableWidgetWithBlocs(
          providers: downloads.providers,
          child: const Scaffold(body: DownloadFeedbackListener(child: SizedBox()))));
      await tester.pump();

      expect(find.text('There is not enough space on this phone for these files.'), findsOneWidget);
    });

    testWidgets('should show the preparation of the files to share and close it', (tester) async {
      downloads = DownloadsTestProviders();
      final states = StreamController<ShareState>();
      addTearDown(states.close);
      whenListen(downloads.share, states.stream, initialState: const ShareIdle());
      await tester.pumpWidget(makeTestableWidgetWithBlocs(
          providers: downloads.providers,
          child: const Scaffold(body: DownloadFeedbackListener(child: SizedBox()))));

      states.add(const SharePreparing(prepared: 1, total: 3));
      await settle(tester);
      expect(find.text('Preparing 1 of 3…'), findsOneWidget);

      states.add(const SharePreparing(prepared: 2, total: 3));
      await settle(tester);
      expect(find.text('Preparing 2 of 3…'), findsOneWidget);

      states.add(const ShareIdle());
      await settle(tester);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should show the failure of sharing', (tester) async {
      downloads = DownloadsTestProviders();
      final states = StreamController<ShareState>();
      addTearDown(states.close);
      whenListen(downloads.share, states.stream, initialState: const ShareIdle());
      await tester.pumpWidget(makeTestableWidgetWithBlocs(
          providers: downloads.providers,
          child: const Scaffold(body: DownloadFeedbackListener(child: SizedBox()))));

      states.add(const SharePreparing(prepared: 0, total: 60));
      await settle(tester);
      states.add(const ShareError(TooManyFilesToShareFailure(messageParams: {'max': 50})));
      await settle(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('You can share up to 50 files at once.'), findsOneWidget);
    });
  });

  test('DeviceStorage keeps its values', () {
    expect(const DeviceStorage(freeBytes: 1, totalBytes: 2), const DeviceStorage(freeBytes: 1, totalBytes: 2));
  });
}
