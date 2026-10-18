import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/plan_download_use_case.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/share_files_use_case.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_plan_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/share_cubit.dart';

import '../../downloads_mocks.dart';

class MockOnDevicePresence extends Mock implements OnDevicePresence {}

class MockPlanDownloadUseCase extends Mock implements PlanDownloadUseCase {}

class MockShareFilesUseCase extends Mock implements ShareFilesUseCase {}

void main() {
  group('OnDevicePresenceCubit', () {
    late MockOnDevicePresence presence;
    late StreamController<void> changes;

    setUp(() {
      presence = MockOnDevicePresence();
      changes = StreamController<void>.broadcast();
      when(() => presence.changes).thenAnswer((_) => changes.stream);
      when(() => presence.isKnown).thenReturn(false);
      when(() => presence.missing).thenReturn([]);
    });

    tearDown(() => changes.close());

    test('should not know anything until the presence is computed', () {
      final cubit = OnDevicePresenceCubit(presence);

      expect(cubit.state.known, isFalse);
      expect(cubit.state.isOnDevice('1'), isNull);
      cubit.close();
    });

    blocTest<OnDevicePresenceCubit, OnDevicePresenceState>(
      'should follow the changes with the missing files and their size',
      build: () => OnDevicePresenceCubit(presence),
      act: (cubit) {
        when(() => presence.isKnown).thenReturn(true);
        when(() => presence.missing).thenReturn([DownloadsTestData.photo, DownloadsTestData.video]);
        changes.add(null);
      },
      verify: (cubit) {
        expect(cubit.state.known, isTrue);
        expect(cubit.state.revision, 1);
        expect(cubit.state.isOnDevice('1'), isFalse);
        expect(cubit.state.isOnDevice('3'), isTrue);
        expect(cubit.state.missingCount, 2);
        expect(cubit.state.missingBytes, 53000000);
      },
    );
  });

  group('DownloadPlanCubit', () {
    late MockPlanDownloadUseCase planDownload;
    final plan = DownloadsTestData.plan([DownloadsTestData.photo], onDevice: 2);

    setUp(() {
      planDownload = MockPlanDownloadUseCase();
      when(() => planDownload(folderId: any(named: 'folderId'), includeSubfolders: any(named: 'includeSubfolders')))
          .thenAnswer((_) async => plan);
    });

    blocTest<DownloadPlanCubit, DownloadPlanState>(
      'should plan the album with its subalbums',
      build: () => DownloadPlanCubit(planDownload, folderId: '10'),
      act: (cubit) => cubit.load(),
      expect: () => [
        const DownloadPlanLoading(includeSubfolders: true),
        DownloadPlanLoaded(plan, includeSubfolders: true),
      ],
      verify: (_) => verify(() => planDownload(folderId: '10', includeSubfolders: true)).called(1),
    );

    blocTest<DownloadPlanCubit, DownloadPlanState>(
      'should plan again without the subalbums',
      build: () => DownloadPlanCubit(planDownload, folderId: '10'),
      act: (cubit) => cubit.setIncludeSubfolders(false),
      expect: () => [
        const DownloadPlanLoading(includeSubfolders: false),
        DownloadPlanLoaded(plan, includeSubfolders: false),
      ],
      verify: (_) => verify(() => planDownload(folderId: '10', includeSubfolders: false)).called(1),
    );

    blocTest<DownloadPlanCubit, DownloadPlanState>(
      'should show the failure when it cannot be planned',
      setUp: () => when(() => planDownload(folderId: any(named: 'folderId'),
          includeSubfolders: any(named: 'includeSubfolders'))).thenThrow(const DeviceMediaUnsupportedFailure()),
      build: () => DownloadPlanCubit(planDownload),
      act: (cubit) => cubit.load(),
      expect: () => [
        const DownloadPlanLoading(includeSubfolders: true),
        isA<DownloadPlanError>().having((s) => s.failure, 'failure', isA<DeviceMediaUnsupportedFailure>()),
      ],
    );
  });

  group('ShareCubit', () {
    late MockShareFilesUseCase shareFiles;
    const files = [DownloadsTestData.photo, DownloadsTestData.video];

    setUp(() {
      shareFiles = MockShareFilesUseCase();
      registerFallbackValue(<RemoteMediaFile>[]);
    });

    blocTest<ShareCubit, ShareState>(
      'should report the preparation and go back to idle once shared',
      setUp: () => when(() => shareFiles(any(), onPrepared: any(named: 'onPrepared'))).thenAnswer((i) async {
        final onPrepared = i.namedArguments[#onPrepared] as void Function(int, int);
        onPrepared(1, 2);
        onPrepared(2, 2);
      }),
      build: () => ShareCubit(shareFiles),
      act: (cubit) => cubit.share(files),
      expect: () => const [
        SharePreparing(prepared: 0, total: 2),
        SharePreparing(prepared: 1, total: 2),
        SharePreparing(prepared: 2, total: 2),
        ShareIdle(),
      ],
    );

    blocTest<ShareCubit, ShareState>(
      'should report the failure',
      setUp: () => when(() => shareFiles(any(), onPrepared: any(named: 'onPrepared')))
          .thenThrow(const TooManyFilesToShareFailure()),
      build: () => ShareCubit(shareFiles),
      act: (cubit) => cubit.share(files),
      expect: () => [
        const SharePreparing(prepared: 0, total: 2),
        isA<ShareError>().having((s) => s.failure, 'failure', isA<TooManyFilesToShareFailure>()),
        const ShareIdle(),
      ],
    );

    blocTest<ShareCubit, ShareState>(
      'should do nothing without files',
      build: () => ShareCubit(shareFiles),
      act: (cubit) => cubit.share([]),
      expect: () => const <ShareState>[],
    );
  });
}
