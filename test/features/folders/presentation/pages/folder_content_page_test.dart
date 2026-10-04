import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/filter_pill.dart';
import 'package:photo_manager_app/core/widgets/media_grid.dart';
import 'package:photo_manager_app/core/widgets/media_grid_skeleton.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/core/widgets/selection_header.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_selection_bar.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_state.dart';
import 'package:photo_manager_app/features/folders/presentation/pages/folder_content_page.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/subfolders_section.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/widgets/selection_action_bar.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_mosaic.dart';

class MockFolderContentBloc extends Mock implements FolderContentBloc {}

class MockFolderBloc extends Mock implements FolderBloc {}

class MockFileManagementBloc extends Mock implements FileManagementBloc {}

class FakeFolderContentEvent extends Fake implements FolderContentEvent {}

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState> implements FavoritesBloc {}

void main() {
  late MockFolderContentBloc contentBloc;
  late MockFolderBloc folderBloc;
  late MockFileManagementBloc fileManagementBloc;
  late MockFavoritesBloc favoritesBloc;

  setUpAll(() => registerFallbackValue(FakeFolderContentEvent()));

  setUp(() {
    contentBloc = MockFolderContentBloc();
    when(() => contentBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => contentBloc.state).thenReturn(const FolderContentStarting());

    fileManagementBloc = MockFileManagementBloc();
    when(() => fileManagementBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => fileManagementBloc.state).thenReturn(const FileManagementStarting());

    favoritesBloc = MockFavoritesBloc();
    when(() => favoritesBloc.state).thenReturn(const FavoritesState());

    folderBloc = MockFolderBloc();
    when(() => folderBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => folderBloc.state).thenReturn(const FolderStarting());
  });

  final album = TestFolders.album(
    id: 'folder-1',
    name: 'Japan',
    parentFolderId: 'parent-1',
    path: '/Trips/Japan',
    fileCount: 2,
    subfolderCount: 1,
  );
  final subalbum = TestFolders.album(id: 'sub-1', name: 'Kyoto', parentFolderId: 'folder-1', fileCount: 5);
  final now = DateTime.now();
  final files = [
    GalleryFile(id: 'file-1', type: FileType.image, status: FileStatus.managed, capturedAt: now),
    GalleryFile(id: 'file-2', type: FileType.video, status: FileStatus.managed, durationSeconds: 30, capturedAt: now),
  ];

  FolderContentLoaded loaded({
    List<GalleryFile>? fileList,
    List<Folder>? subfolders,
    FileFilter filter = FileFilter.all,
    bool isSelectionMode = false,
    Set<String> selected = const {},
  }) {
    final list = fileList ?? files;
    return FolderContentLoaded(
      currentFolder: album,
      subfolders: subfolders ?? [subalbum],
      files: list,
      groupedFiles: DateGroupingUtil.groupFilesByDate(list),
      hasMoreFiles: false,
      totalFilesCount: list.length,
      currentFilter: filter,
      isSelectionMode: isSelectionMode,
      selectedFileIds: selected,
    );
  }

  /// Thumbnails keep loading in tests, so pumpAndSettle never settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpPage(WidgetTester tester, FolderContentState state) async {
    setUpCustomScreenSize(tester, 390, 1400);
    when(() => contentBloc.state).thenReturn(state);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<FolderContentBloc>.value(value: contentBloc),
        BlocProvider<FolderBloc>.value(value: folderBloc),
        BlocProvider<FileManagementBloc>.value(value: fileManagementBloc),
        BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
      ],
      child: const FolderContentPage(folderId: 'folder-1'),
    ));
  }

  group('FolderContentPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the back bar, breadcrumbs, title and item count', (tester) async {
      // Arrange & Act
      await pumpPage(tester, loaded());

      // Assert
      expect(find.byType(SecondaryTopBar), findsOneWidget);
      expect(find.text('Albums › Trips'), findsOneWidget);
      expect(find.text('Japan'), findsOneWidget);
      expect(find.text('2 items'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should show the item count with the months of the album', (tester) async {
      // Arrange
      final dated = FolderContentLoaded(
        currentFolder: TestFolders.album(
          id: 'folder-1',
          name: 'Japan',
          parentFolderId: 'parent-1',
          path: '/Trips/Japan',
          fileCount: 2,
          subfolderCount: 1,
          oldestCapturedAt: DateTime(2024, 8, 2),
          newestCapturedAt: DateTime(2024, 8, 14),
        ),
        subfolders: [
          TestFolders.album(
            id: 'sub-1',
            name: 'Kyoto',
            parentFolderId: 'folder-1',
            fileCount: 5,
            oldestCapturedAt: DateTime(2023, 12, 30),
            newestCapturedAt: DateTime(2024, 1, 2),
          ),
        ],
        files: files,
        groupedFiles: DateGroupingUtil.groupFilesByDate(files),
        hasMoreFiles: false,
        totalFilesCount: files.length,
        isSelectionMode: false,
        selectedFileIds: const {},
      );

      // Act
      await pumpPage(tester, dated);

      // Assert
      expect(find.text('2 items · Aug 2024'), findsOneWidget);
      expect(find.text('Dec 2023 – Jan 2024'), findsOneWidget);
    });

    // ==================== FAVORITES TESTS ====================

    group('with favorites on', () {
      setUp(() => AppConfig.favoritesAndCoversEnabled = true);
      tearDown(() => AppConfig.favoritesAndCoversEnabled = false);

      final favorite = GalleryFile(id: 'file-1', type: FileType.image, status: FileStatus.managed, capturedAt: now, isFavorite: true);
      final plain = GalleryFile(id: 'file-2', type: FileType.image, status: FileStatus.managed, capturedAt: now);

      testWidgets('should show Favorites, Move and Delete in the album selection', (tester) async {
        // Arrange & Act
        await pumpPage(tester, loaded(fileList: [favorite, plain], isSelectionMode: true, selected: {'file-1', 'file-2'}));

        // Assert
        final bar = find.byType(SelectionActionBar);
        for (final label in ['Favorites', 'Move', 'Delete']) {
          expect(find.descendant(of: bar, matching: find.text(label)), findsOneWidget);
        }
        expect(find.descendant(of: bar, matching: find.text('Save')), findsNothing);
      });

      testWidgets('should mark the whole selection and leave selection mode', (tester) async {
        // Arrange
        await pumpPage(tester, loaded(fileList: [favorite, plain], isSelectionMode: true, selected: {'file-1', 'file-2'}));

        // Act
        await tester.tap(find.descendant(of: find.byType(SelectionActionBar), matching: find.text('Favorites')));

        // Assert
        verify(() => favoritesBloc.add(SetFavorites(files: [favorite, plain], favorite: true))).called(1);
        verify(() => contentBloc.add(const ExitSelectionMode())).called(1);
      });

      testWidgets('should offer to remove when every selected file is a favorite', (tester) async {
        // Arrange
        await pumpPage(tester, loaded(fileList: [favorite, plain], isSelectionMode: true, selected: {'file-1'}));

        // Act
        await tester.tap(find.text('Remove from favorites'));

        // Assert
        verify(() => favoritesBloc.add(SetFavorites(files: [favorite], favorite: false))).called(1);
      });

      testWidgets('should confirm how many were added', (tester) async {
        // Arrange
        whenListen(
          favoritesBloc,
          Stream.value(const FavoritesState(outcome: FavoritesSaved(count: 3, favorite: true))),
          initialState: const FavoritesState(),
        );

        // Act
        await pumpPage(tester, loaded());
        await tester.pump();

        // Assert
        expect(find.text('3 added to favorites'), findsOneWidget);
      });

      testWidgets('should tell when favorites could not be updated', (tester) async {
        // Arrange
        whenListen(
          favoritesBloc,
          Stream.value(const FavoritesState(outcome: FavoritesFailed(NetworkFailure()))),
          initialState: const FavoritesState(),
        );

        // Act
        await pumpPage(tester, loaded());
        await tester.pump();

        // Assert
        expect(find.text("Couldn't update. Please try again."), findsOneWidget);
      });
    });

    testWidgets('should show the sub-album mosaic with its radius when covers are on', (tester) async {
      // Arrange
      AppConfig.favoritesAndCoversEnabled = true;
      addTearDown(() => AppConfig.favoritesAndCoversEnabled = false);

      // Act
      await pumpPage(tester, loaded(subfolders: [
        TestFolders.album(id: 'sub-1', name: 'Kyoto', parentFolderId: 'folder-1', fallbackCoverFileIds: ['5', '6']),
      ]));

      // Assert
      final mosaic = tester.widget<AlbumMosaic>(
        find.descendant(of: find.byType(SubfoldersSection), matching: find.byType(AlbumMosaic)),
      );
      expect(mosaic.fileIds, ['5', '6']);
      expect(mosaic.radius, 16);
      expect(mosaic.iconSize, 28);
    });

    testWidgets('should keep the gallery selection actions while favorites are off', (tester) async {
      // Arrange & Act
      await pumpPage(tester, loaded(isSelectionMode: true, selected: {'file-1'}));

      // Assert
      expect(find.descendant(of: find.byType(SelectionActionBar), matching: find.text('Save')), findsOneWidget);
      expect(find.text('Move'), findsNothing);
    });

    testWidgets('should list sub-albums with a create card', (tester) async {
      // Arrange & Act
      await pumpPage(tester, loaded());

      // Assert
      expect(find.byType(SubfoldersSection), findsOneWidget);
      expect(find.text('Kyoto'), findsOneWidget);
      expect(find.text('Sub-album'), findsOneWidget);
    });

    testWidgets('should open the new sub-album sheet from the dashed card', (tester) async {
      // Arrange
      await pumpPage(tester, loaded());

      // Act
      await tester.tap(find.text('Sub-album'));
      await settle(tester);

      // Assert
      final sheet = tester.widget<CreateFolderModal>(find.byType(CreateFolderModal));
      expect(sheet.parentFolderId, 'folder-1');
    });

    testWidgets('should open the new sub-album sheet from the more menu', (tester) async {
      // Arrange
      await pumpPage(tester, loaded());

      // Act
      await tester.tap(find.byTooltip('More options'));
      await settle(tester);
      await tester.tap(find.text('New sub-album'));
      await settle(tester);

      // Assert
      expect(find.byType(CreateFolderModal), findsOneWidget);
    });

    testWidgets('should offer only all/photos/videos filters', (tester) async {
      // Arrange & Act
      await pumpPage(tester, loaded(filter: FileFilter.videos));

      // Assert
      final pills = tester.widgetList<FilterPill>(find.byType(FilterPill)).toList();
      expect(pills.map((p) => p.label), ['All', 'Photos', 'Videos']);
      expect(pills.last.selected, isTrue);
    });

    testWidgets('should filter the album content', (tester) async {
      // Arrange
      await pumpPage(tester, loaded());

      // Act
      await tester.tap(find.text('Photos'));

      // Assert
      verify(() => contentBloc.add(const FilterFilesInFolder(filter: FileFilter.images))).called(1);
    });

    testWidgets('should render the files in the media grid', (tester) async {
      // Arrange & Act
      await pumpPage(tester, loaded());

      // Assert
      expect(find.byType(MediaGrid), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    // ==================== SELECTION MODE TESTS ====================

    testWidgets('should show the selection header in selection mode', (tester) async {
      // Arrange & Act
      await pumpPage(tester, loaded(isSelectionMode: true, selected: const {'file-1'}));

      // Assert
      expect(find.byType(SelectionHeader), findsOneWidget);
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byType(SecondaryTopBar), findsNothing);
      expect(find.byType(ManageSelectionBar), findsOneWidget);
    });

    testWidgets('should select every file from the header', (tester) async {
      // Arrange
      await pumpPage(tester, loaded(isSelectionMode: true, selected: const {'file-1'}));

      // Act (the "All" filter pill is also visible)
      await tester.tap(find.descendant(of: find.byType(SelectionHeader), matching: find.text('All')));

      // Assert
      verify(() => contentBloc.add(const SelectAllFiles())).called(1);
    });

    // ==================== LOADING & EMPTY STATE TESTS ====================

    testWidgets('should show the skeleton while loading', (tester) async {
      // Arrange & Act
      await pumpPage(tester, const FolderContentLoading());

      // Assert
      expect(find.byType(MediaGridSkeleton), findsOneWidget);
    });

    testWidgets('should show the empty album state', (tester) async {
      // Arrange & Act
      await pumpPage(tester, loaded(fileList: const [], subfolders: const []));

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('This album is empty'), findsOneWidget);
    });

    testWidgets('should handle many files', (tester) async {
      // Arrange
      final many = List.generate(
        60,
        (i) => GalleryFile(id: 'f$i', type: FileType.image, status: FileStatus.managed, capturedAt: now),
      );

      // Act
      await pumpPage(tester, loaded(fileList: many));

      // Assert
      expect(find.byType(MediaGrid), findsOneWidget);
    });
  });
}
