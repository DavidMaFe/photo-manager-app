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

class MockFolderContentBloc extends Mock implements FolderContentBloc {}

class MockFolderBloc extends Mock implements FolderBloc {}

class FakeFolderContentEvent extends Fake implements FolderContentEvent {}

void main() {
  late MockFolderContentBloc contentBloc;
  late MockFolderBloc folderBloc;

  setUpAll(() => registerFallbackValue(FakeFolderContentEvent()));

  setUp(() {
    contentBloc = MockFolderContentBloc();
    when(() => contentBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => contentBloc.state).thenReturn(const FolderContentStarting());

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
      expect(find.byType(FloatingActionButton), findsOneWidget);
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
