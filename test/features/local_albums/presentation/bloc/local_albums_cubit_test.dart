import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/finish_local_albums_review_use_case.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/register_local_albums_use_case.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/set_local_album_modes_use_case.dart';
import 'package:photo_manager_app/features/local_albums/presentation/bloc/local_albums_cubit.dart';

import '../../../../fixtures/test_data.dart';

class MockRegisterLocalAlbumsUseCase extends Mock implements RegisterLocalAlbumsUseCase {}

class MockSetLocalAlbumModesUseCase extends Mock implements SetLocalAlbumModesUseCase {}

class MockFinishLocalAlbumsReviewUseCase extends Mock implements FinishLocalAlbumsReviewUseCase {}

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  late MockRegisterLocalAlbumsUseCase register;
  late MockSetLocalAlbumModesUseCase setModes;
  late MockFinishLocalAlbumsReviewUseCase finish;
  late MockPermissionService permissions;

  final vacaciones = TestLocalAlbums.vacacionesOnServer.withAssetCount(600);
  final camera = TestLocalAlbums.cameraOnServer.withAssetCount(1500);

  setUpAll(() => registerFallbackValue(<String, LocalAlbumMode>{}));

  setUp(() {
    register = MockRegisterLocalAlbumsUseCase();
    setModes = MockSetLocalAlbumModesUseCase();
    finish = MockFinishLocalAlbumsReviewUseCase();
    permissions = MockPermissionService();
    when(() => permissions.isGranted(AppPermission.photos)).thenAnswer((_) async => true);
    when(() => permissions.isPhotoAccessLimited()).thenAnswer((_) async => false);
  });

  LocalAlbumsCubit build() => LocalAlbumsCubit(
      registerLocalAlbums: register, setLocalAlbumModes: setModes, finishLocalAlbumsReview: finish,
      permissionService: permissions);

  group('LocalAlbumsCubit', () {
    group('load', () {
      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should register the albums of the gallery and show them by name',
        setUp: () => when(() => register()).thenAnswer((_) async => [vacaciones, camera]),
        build: build,
        act: (cubit) => cubit.load(),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          const LocalAlbumsState(),
          LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [camera, vacaciones]),
        ],
      );

      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should say when only some photos can be read',
        setUp: () {
          when(() => register()).thenAnswer((_) async => [camera]);
          when(() => permissions.isPhotoAccessLimited()).thenAnswer((_) async => true);
        },
        build: build,
        act: (cubit) => cubit.load(),
        wait: const Duration(milliseconds: 900),
        skip: 1,
        expect: () => [LocalAlbumsState(status: LocalAlbumsStatus.loaded, albums: [camera], limitedAccess: true)],
      );

      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should say the photo access is missing, without registering anything',
        setUp: () => when(() => permissions.isGranted(AppPermission.photos)).thenAnswer((_) async => false),
        build: build,
        act: (cubit) => cubit.load(),
        wait: const Duration(milliseconds: 900),
        skip: 1,
        expect: () => [const LocalAlbumsState(status: LocalAlbumsStatus.noPermission)],
        verify: (_) => verifyNever(() => register()),
      );

      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should show an error when the albums cannot be registered',
        setUp: () => when(() => register()).thenThrow(Exception('Network error')),
        build: build,
        act: (cubit) => cubit.load(),
        wait: const Duration(milliseconds: 900),
        skip: 1,
        expect: () => [isA<LocalAlbumsState>().having((s) => s.status, 'status', LocalAlbumsStatus.error)],
      );
    });

    group('Tus álbumes', () {
      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should keep the changes until «Continuar», and forget the ones that go back to the option of the server',
        build: build,
        act: (cubit) => cubit
          ..show([vacaciones, camera])
          ..choose(camera.localAlbumId, LocalAlbumMode.excluded)
          ..choose(vacaciones.localAlbumId, LocalAlbumMode.backupOnly)
          ..choose(vacaciones.localAlbumId, LocalAlbumMode.album),
        verify: (cubit) {
          expect(cubit.state.changes, {camera.localAlbumId: LocalAlbumMode.excluded});
          expect(cubit.state.modeOf(camera), LocalAlbumMode.excluded);
          expect(cubit.state.excludedCount, 1);
        },
      );

      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should save the changes with «Continuar» and finish',
        setUp: () => when(() => finish(any())).thenAnswer((_) async {}),
        build: build,
        act: (cubit) async {
          cubit
            ..show([vacaciones, camera])
            ..choose(camera.localAlbumId, LocalAlbumMode.excluded);
          await cubit.finish();
        },
        verify: (cubit) {
          verify(() => finish({camera.localAlbumId: LocalAlbumMode.excluded})).called(1);
          expect(cubit.state.status, LocalAlbumsStatus.done);
        },
      );

      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should stay on the page with an error when the changes cannot be saved',
        setUp: () => when(() => finish(any())).thenThrow(Exception('Network error')),
        build: build,
        act: (cubit) async {
          cubit.show([vacaciones]);
          await cubit.finish();
        },
        verify: (cubit) {
          expect(cubit.state.status, LocalAlbumsStatus.loaded);
          expect(cubit.state.saving, isFalse);
          expect(cubit.state.failure, isNotNull);
        },
      );
    });

    group('settings', () {
      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should save each change at once and keep the number of files',
        setUp: () => when(() => setModes({camera.localAlbumId: LocalAlbumMode.excluded})).thenAnswer((_) async => [
              LocalAlbum(localAlbumId: camera.localAlbumId, name: camera.name, mode: LocalAlbumMode.excluded),
            ]),
        build: build,
        act: (cubit) async {
          cubit.show([camera]);
          await cubit.change(camera.localAlbumId, LocalAlbumMode.excluded);
        },
        verify: (cubit) {
          expect(cubit.state.albums.single.mode, LocalAlbumMode.excluded);
          expect(cubit.state.albums.single.assetCount, 1500);
          expect(cubit.state.changes, isEmpty);
          expect(cubit.state.saving, isFalse);
        },
      );

      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should go back to the previous option when the server does not take the change',
        setUp: () => when(() => setModes(any())).thenThrow(Exception('Network error')),
        build: build,
        act: (cubit) async {
          cubit.show([camera]);
          await cubit.change(camera.localAlbumId, LocalAlbumMode.excluded);
        },
        verify: (cubit) {
          expect(cubit.state.modeOf(cubit.state.albums.single), LocalAlbumMode.backupOnly);
          expect(cubit.state.failure, isNotNull);
        },
      );
    });

    group('requestPermission', () {
      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should load the albums when the access is granted',
        setUp: () {
          when(() => permissions.request(AppPermission.photos)).thenAnswer((_) async => true);
          when(() => register()).thenAnswer((_) async => [camera]);
        },
        build: build,
        act: (cubit) => cubit.requestPermission(),
        wait: const Duration(milliseconds: 900),
        verify: (cubit) => expect(cubit.state.status, LocalAlbumsStatus.loaded),
      );

      blocTest<LocalAlbumsCubit, LocalAlbumsState>(
        'should open the system settings when the access is denied',
        setUp: () {
          when(() => permissions.request(AppPermission.photos)).thenAnswer((_) async => false);
          when(() => permissions.openSettings()).thenAnswer((_) async {});
        },
        build: build,
        act: (cubit) => cubit.requestPermission(),
        verify: (_) => verify(() => permissions.openSettings()).called(1),
      );
    });
  });
}
