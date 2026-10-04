import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_thumbnail_strip.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_top_bar.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:photo_manager_app/features/favorites/presentation/widgets/favorite_viewer_button.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/pages/file_detail_page.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_properties_sheet.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

import '../../../../helpers/widget_test_helper.dart';
import 'package:photo_manager_app/features/file_management/presentation/models/album_viewer_context.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/cover_picker/cover_picker_cubit.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/cover_picker/cover_picker_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/cover_picker_sheet.dart';

class MockFileManagementBloc extends Mock implements FileManagementBloc {}

class MockManageFolderBloc extends Mock implements ManageFolderBloc {}

class FakeFileManagementEvent extends Fake implements FileManagementEvent {}

class MockFileInfoBloc extends MockBloc<FileInfoEvent, FileInfoState> implements FileInfoBloc {}

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState> implements FavoritesBloc {}

class MockCoverPickerCubit extends MockCubit<CoverPickerState> implements CoverPickerCubit {}

void main() {
  late MockFileManagementBloc mockFileManagementBloc;
  late MockManageFolderBloc mockManageFolderBloc;
  late MockFileInfoBloc mockFileInfoBloc;
  late MockFavoritesBloc mockFavoritesBloc;

  setUpAll(() => registerFallbackValue(FakeFileManagementEvent()));

  // The properties sheet takes its bloc from the service locator.
  setUp(() {
    mockFileInfoBloc = MockFileInfoBloc();
    when(() => mockFileInfoBloc.state).thenReturn(const FileInfoLoading());
    sl.registerFactory<FileInfoBloc>(() => mockFileInfoBloc);

    mockFavoritesBloc = MockFavoritesBloc();
    when(() => mockFavoritesBloc.state).thenReturn(const FavoritesState());
  });

  tearDown(() => sl.unregister<FileInfoBloc>());

  setUp(() {
    mockFileManagementBloc = MockFileManagementBloc();
    mockManageFolderBloc = MockManageFolderBloc();

    when(() => mockFileManagementBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockFileManagementBloc.state).thenReturn(const FileManagementStarting());

    when(() => mockManageFolderBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockManageFolderBloc.state).thenReturn(const ManageFolderStarting());
  });

  final now = DateTime.now();
  final testFiles = [
    GalleryFile(id: 'file-1', type: FileType.image, status: FileStatus.managed, capturedAt: now),
    GalleryFile(id: 'file-2', type: FileType.image, status: FileStatus.pending, capturedAt: now),
    GalleryFile(
      id: 'file-3',
      type: FileType.video,
      status: FileStatus.managed,
      durationSeconds: 75,
      capturedAt: DateTime(2024, 1, 15, 10, 42),
    ),
  ];

  Widget createWidgetUnderTest({
    required List<GalleryFile> files,
    int initialIndex = 0,
    AlbumViewerContext? albumContext,
  }) {
    return makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<FileManagementBloc>.value(value: mockFileManagementBloc),
        BlocProvider<ManageFolderBloc>.value(value: mockManageFolderBloc),
        BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
      ],
      child: FileDetailPage(files: files, initialIndex: initialIndex, albumContext: albumContext),
    );
  }

  /// The viewer images show endless loading spinners, so pumpAndSettle never settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  double chromeOpacity(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(find.ancestor(
        of: find.byType(MediaViewerTopBar),
        matching: find.byType(AnimatedOpacity),
      ))
      .opacity;

  group('FileDetailPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should use the black media background and a page view', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppPalette.light.media);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should show the capture day and time in the top bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      final bar = tester.widget<MediaViewerTopBar>(find.byType(MediaViewerTopBar));
      expect(bar.title, startsWith('Today, '));
      expect(bar.subtitle, 'Image');
    });

    testWidgets('should show "No date" in the top bar when the file has no capture date', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: const [
        GalleryFile(id: 'undated', type: FileType.image, status: FileStatus.managed, capturedAt: null),
      ]));

      // Assert
      expect(tester.widget<MediaViewerTopBar>(find.byType(MediaViewerTopBar)).title, 'No date');
    });

    testWidgets('should show the type and duration for older videos', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles, initialIndex: 2));

      // Assert
      final bar = tester.widget<MediaViewerTopBar>(find.byType(MediaViewerTopBar));
      expect(bar.title, 'Jan 15, 2024, 10:42');
      expect(bar.subtitle, 'Video · 1:15');
    });

    testWidgets('should hide the review pill for managed files', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      expect(find.byType(MediaViewerReviewPill), findsNothing);
    });

    testWidgets('should show the review pill for pending files', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles, initialIndex: 1));

      // Assert
      expect(find.byType(MediaViewerReviewPill), findsOneWidget);
      expect(find.text('To review'), findsOneWidget);
    });

    testWidgets('should show the save and delete actions without favorite or share', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    // ==================== THUMBNAIL STRIP TESTS ====================

    testWidgets('should show the favorite button before save when favorites are on', (tester) async {
      // Arrange
      AppConfig.favoritesAndCoversEnabled = true;
      addTearDown(() => AppConfig.favoritesAndCoversEnabled = false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      expect(find.byType(FavoriteViewerButton), findsOneWidget);
      expect(
        tester.getCenter(find.byType(FavoriteViewerButton)).dx,
        lessThan(tester.getCenter(find.text('Save')).dx),
      );
    });

    // ==================== ALBUM CONTEXT TESTS ====================

    group('opened from an album', () {
      setUp(() => AppConfig.favoritesAndCoversEnabled = true);
      tearDown(() => AppConfig.favoritesAndCoversEnabled = false);

      const album = AlbumViewerContext(
        folderId: 'a3',
        folderName: 'Atardeceres',
        path: 'Vacaciones 2024 › Playa › Atardeceres',
        albumNames: {'a3': 'Atardeceres', 'a2': 'Playa'},
      );
      GalleryFile photo({List<String> coverOf = const []}) =>
          GalleryFile(id: 'p1', type: FileType.image, status: FileStatus.managed, capturedAt: now, coverOf: coverOf);

      testWidgets('should show the album path in the header', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(files: [photo()], albumContext: album));
        expect(tester.widget<MediaViewerTopBar>(find.byType(MediaViewerTopBar)).subtitle, album.path);
      });

      testWidgets('should show Favorite, Cover, Move and Delete', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createWidgetUnderTest(files: [photo()], albumContext: album));

        // Assert
        expect(find.byType(FavoriteViewerButton), findsOneWidget);
        expect(find.byType(MediaViewerCoverAction), findsOneWidget);
        for (final label in ['Cover', 'Move', 'Delete']) {
          expect(find.text(label), findsOneWidget);
        }
        expect(find.text('Save'), findsNothing);
      });

      testWidgets('should meet the tap target guideline in the album bar', (tester) async {
        // Arrange
        final handle = tester.ensureSemantics();

        // Act
        await tester.pumpWidget(createWidgetUnderTest(files: [photo(coverOf: ['a2'])], albumContext: album));

        // Assert
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('should not offer Cover for videos', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createWidgetUnderTest(files: [testFiles[2]], albumContext: album));

        // Assert
        expect(find.byType(MediaViewerCoverAction), findsNothing);
        expect(find.text('Move'), findsOneWidget);
      });

      testWidgets('should name the album a photo is the cover of', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(files: [photo(coverOf: ['a2'])], albumContext: album));
        expect(find.text('Cover of Playa'), findsOneWidget);
      });

      testWidgets('should count the albums a photo is the cover of', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(files: [photo(coverOf: ['a1', 'a3'])], albumContext: album));
        expect(find.text('Cover of 2 albums'), findsOneWidget);
      });

      testWidgets('should not show the pill when the photo is no cover', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(files: [photo()], albumContext: album));
        expect(find.byType(MediaViewerCoverPill), findsNothing);
      });

      testWidgets('should open the cover sheet for the photo', (tester) async {
        // Arrange
        final cubit = MockCoverPickerCubit();
        when(() => cubit.state).thenReturn(const CoverPickerState(fileIds: ['p1']));
        when(() => cubit.load(any())).thenAnswer((_) async {});
        sl.registerFactory<CoverPickerCubit>(() => cubit);
        addTearDown(() => sl.unregister<CoverPickerCubit>());
        await tester.pumpWidget(createWidgetUnderTest(files: [photo()], albumContext: album));

        // Act
        await tester.tap(find.text('Cover'));
        await settle(tester);

        // Assert
        expect(find.byType(CoverPickerSheet), findsOneWidget);
        verify(() => cubit.load(['p1'])).called(1);
      });

      testWidgets('should open the album option of the manage sheet from Move', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(files: [photo()], albumContext: album));

        // Act
        await tester.tap(find.text('Move'));
        await settle(tester);

        // Assert
        expect(tester.widget<ManageFileModal>(find.byType(ManageFileModal)).initialOption, ManageOption.album);
      });
    });

    testWidgets('should ignore the album context while covers are off', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        files: testFiles,
        albumContext: const AlbumViewerContext(folderId: 'a', folderName: 'A', path: 'A'),
      ));

      // Assert
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Move'), findsNothing);
    });

    testWidgets('should hide the favorite button while favorites are off', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));
      expect(find.byType(FavoriteViewerButton), findsNothing);
    });

    testWidgets('should show the thumbnail strip for several files', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles, initialIndex: 1));

      // Assert
      final strip = tester.widget<MediaViewerThumbnailStrip>(find.byType(MediaViewerThumbnailStrip));
      expect(strip.itemCount, 3);
      expect(strip.currentIndex, 1);
    });

    testWidgets('should hide the thumbnail strip for a single file', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: [testFiles.first]));

      // Assert
      expect(find.byType(MediaViewerThumbnailStrip), findsNothing);
    });

    testWidgets('should keep the strip in sync with the page view', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Act
      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await settle(tester);

      // Assert
      final strip = tester.widget<MediaViewerThumbnailStrip>(find.byType(MediaViewerThumbnailStrip));
      expect(strip.currentIndex, 1);
    });

    // ==================== CHROME VISIBILITY TESTS ====================

    testWidgets('should hide and show the chrome when tapping the photo', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));
      expect(chromeOpacity(tester), 1);

      // Act
      await tester.tapAt(const Offset(400, 300));
      await settle(tester);
      final hidden = chromeOpacity(tester);
      await tester.tapAt(const Offset(400, 300));
      await settle(tester);

      // Assert
      expect(hidden, 0);
      expect(chromeOpacity(tester), 1);
    });

    // ==================== ACTION TESTS ====================

    testWidgets('should open the properties sheet from the info button', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Act
      await tester.tap(find.byTooltip('Info'));
      await settle(tester);

      // Assert
      expect(find.byType(FilePropertiesSheet), findsOneWidget);
      verify(() => mockFileInfoBloc.add(const LoadFileInfo('file-1'))).called(1);
    });

    testWidgets('should confirm before deleting and dispatch the delete action', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles, initialIndex: 1));

      // Act
      await tester.tap(find.text('Delete'));
      await settle(tester);
      expect(find.byType(AppDialog), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.text('Delete')));
      await settle(tester);

      // Assert
      final event = verify(() => mockFileManagementBloc.add(captureAny())).captured.single;
      expect(
        event,
        const ManagedFilesRequested(
          fileIds: ['file-2'],
          action: ManageAction(serverAction: ServerAction.delete, keepOnDevice: false),
        ),
      );
    });

    testWidgets('should not delete when the confirmation is cancelled', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Act
      await tester.tap(find.text('Delete'));
      await settle(tester);
      await tester.tap(find.text('Cancel'));
      await settle(tester);

      // Assert
      verifyNever(() => mockFileManagementBloc.add(any()));
    });

    testWidgets('should close the viewer after a successful delete', (tester) async {
      // Arrange
      final navigatorKey = GlobalKey<NavigatorState>();
      when(() => mockFileManagementBloc.stream).thenAnswer((_) => Stream.fromFuture(
            Future.delayed(
              const Duration(milliseconds: 10),
              () => const FileManagementSuccess(message: 'Deleted', processedCount: 1),
            ),
          ));
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: Text('Gallery')), navigatorKey: navigatorKey));
      navigatorKey.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<FileManagementBloc>.value(value: mockFileManagementBloc),
            BlocProvider<ManageFolderBloc>.value(value: mockManageFolderBloc),
          ],
          child: FileDetailPage(files: testFiles, initialIndex: 0),
        ),
      ));

      // Act: the push, the success state and the pop transition.
      await settle(tester);
      await settle(tester);

      // Assert
      expect(find.byType(FileDetailPage), findsNothing);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Deleted'), findsOneWidget);
    });

    testWidgets('should dispose cleanly', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Act
      await tester.pumpWidget(const SizedBox());

      // Assert
      expect(find.byType(FileDetailPage), findsNothing);
    });
  });
}
