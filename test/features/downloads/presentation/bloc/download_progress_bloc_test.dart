import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/cancel_download_use_case.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/start_download_use_case.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_state.dart';

import '../../downloads_mocks.dart';

class MockStartDownloadUseCase extends Mock implements StartDownloadUseCase {}

class MockCancelDownloadUseCase extends Mock implements CancelDownloadUseCase {}

class MockOnDevicePresence extends Mock implements OnDevicePresence {}

void main() {
  late MockDownloadQueueRepository queue;
  late MockStartDownloadUseCase startDownload;
  late MockCancelDownloadUseCase cancelDownload;
  late MockOnDevicePresence presence;
  late DateTime now;

  const running = DownloadProgress(total: 4, saved: 1, failed: 0, bytesTotal: 100, bytesSaved: 0, currentAlbum: 'Trip');
  const finished = DownloadProgress(total: 4, saved: 3, failed: 1, bytesTotal: 100, bytesSaved: 90);
  final plan = DownloadsTestData.plan([DownloadsTestData.photo]);

  DownloadProgressBloc build() => DownloadProgressBloc(
        queue: queue,
        startDownload: startDownload,
        cancelDownload: cancelDownload,
        presence: presence,
        clock: () => now,
      );

  setUpAll(() => registerFallbackValue(DownloadsTestData.plan([])));

  setUp(() {
    queue = MockDownloadQueueRepository();
    startDownload = MockStartDownloadUseCase();
    cancelDownload = MockCancelDownloadUseCase();
    presence = MockOnDevicePresence();
    now = DateTime(2026, 10, 17, 10);
    when(() => queue.progress()).thenAnswer((_) async => DownloadProgress.empty);
    when(() => queue.savedIds()).thenAnswer((_) async => []);
    when(() => startDownload(any(), album: any(named: 'album'))).thenAnswer((_) async {});
    when(() => cancelDownload()).thenAnswer((_) async {});
  });

  group('DownloadProgressBloc', () {
    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should show nothing when no download is queued',
      build: build,
      act: (bloc) => bloc.add(const DownloadProgressWatchRequested()),
      expect: () => [const DownloadProgressState()],
      verify: (bloc) => expect(bloc.state.isVisible, isFalse),
    );

    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should follow a running download and mark the saved files as on the device once',
      setUp: () {
        when(() => queue.progress()).thenAnswer((_) async => running);
        when(() => queue.savedIds()).thenAnswer((_) async => ['1']);
      },
      build: build,
      act: (bloc) async {
        bloc.add(const DownloadProgressWatchRequested());
        await Future<void>.delayed(Duration.zero);
        when(() => queue.savedIds()).thenAnswer((_) async => ['1', '2']);
        bloc.add(const DownloadProgressPolled());
      },
      expect: () => [const DownloadProgressState(progress: running)],
      verify: (bloc) {
        verify(() => presence.markOnDevice(['1'])).called(1);
        verify(() => presence.markOnDevice(['2'])).called(1);
        expect(bloc.state.isRunning, isTrue);
        expect(bloc.state.isVisible, isTrue);
      },
    );

    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should read the queue every second while the download runs',
      setUp: () => when(() => queue.progress()).thenAnswer((_) async => running),
      build: build,
      act: (bloc) async {
        bloc.add(const DownloadProgressWatchRequested());
        await Future<void>.delayed(const Duration(milliseconds: 2300));
      },
      verify: (_) => verify(() => queue.progress()).called(greaterThanOrEqualTo(3)),
    );

    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should estimate the time left from the speed so far',
      build: build,
      act: (bloc) async {
        when(() => queue.progress()).thenAnswer((_) async => running);
        bloc.add(const DownloadProgressWatchRequested());
        await Future<void>.delayed(Duration.zero);
        now = now.add(const Duration(seconds: 10));
        when(() => queue.progress()).thenAnswer((_) async =>
            const DownloadProgress(total: 4, saved: 2, failed: 0, bytesTotal: 100, bytesSaved: 50));
        bloc.add(const DownloadProgressPolled());
      },
      skip: 1,
      expect: () => [
        const DownloadProgressState(
          progress: DownloadProgress(total: 4, saved: 2, failed: 0, bytesTotal: 100, bytesSaved: 50),
          remaining: Duration(seconds: 10),
        ),
      ],
    );

    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should queue the plan into its album and follow it',
      setUp: () => when(() => queue.progress()).thenAnswer((_) async => running),
      build: build,
      act: (bloc) => bloc.add(DownloadRequested(plan, album: 'Trip')),
      expect: () => [const DownloadProgressState(progress: running)],
      verify: (_) => verify(() => startDownload(plan, album: 'Trip')).called(1),
    );

    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should keep the failure when the download cannot start',
      setUp: () => when(() => startDownload(any(), album: any(named: 'album')))
          .thenThrow(const NotEnoughSpaceFailure()),
      build: build,
      act: (bloc) => bloc.add(DownloadRequested(plan)),
      expect: () => [isA<DownloadProgressState>().having((s) => s.failure, 'failure', isA<NotEnoughSpaceFailure>())],
    );

    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should cancel the download and show what was saved',
      setUp: () => when(() => queue.progress()).thenAnswer((_) async => finished),
      build: build,
      act: (bloc) => bloc.add(const DownloadCancelRequested()),
      expect: () => [const DownloadProgressState(progress: finished)],
      verify: (_) => verify(() => cancelDownload()).called(1),
    );

    blocTest<DownloadProgressBloc, DownloadProgressState>(
      'should hide a finished download once dismissed',
      setUp: () => when(() => queue.progress()).thenAnswer((_) async => finished),
      build: build,
      act: (bloc) async {
        bloc.add(const DownloadProgressWatchRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DownloadProgressDismissed());
      },
      expect: () => [
        const DownloadProgressState(progress: finished),
        const DownloadProgressState(progress: finished, dismissed: true),
      ],
      verify: (bloc) => expect(bloc.state.isVisible, isFalse),
    );
  });

  test('DownloadPlan of the test data fits', () => expect(plan.fits, isTrue));

  test('DownloadPlan without files is empty', () => expect(const DownloadPlan(toDownload: [], alreadyOnDevice: 0,
      storage: DownloadsTestData.roomyStorage).isEmpty, isTrue));
}
