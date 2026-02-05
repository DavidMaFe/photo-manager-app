import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:photo_manager_app/features/gallery/presentation/pages/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/filter_chips.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockGalleryBloc extends Mock implements GalleryBloc {}

void main() {
  late MockGalleryBloc mockGalleryBloc;

  setUp(() {
    mockGalleryBloc = MockGalleryBloc();
    when(() => mockGalleryBloc.stream)
        .thenAnswer((_) => Stream.value(const GalleryStarting()));
    when(() => mockGalleryBloc.state).thenReturn(const GalleryStarting());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<GalleryBloc>.value(
        value: mockGalleryBloc,
        child: const GalleryPage(),
      ),
    );
  }

  final testDate = DateTime(2024, 1, 15);

  final testFiles = [
    GalleryFile(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testDate,
    ),
    GalleryFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.pending,
      durationSeconds: 120,
      capturedAt: testDate,
    ),
  ];

  // Helper to create grouped files for tests
  List<FileDateGroup> groupTestFiles(List<GalleryFile> files) {
    return DateGroupingUtil.groupFilesByDate(files);
  }

  group('GalleryPage', () {
    testWidgets('should render Scaffold', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render GalleryHeader as app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should use BlocConsumer to listen to GalleryBloc', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(BlocConsumer<GalleryBloc, GalleryState>), findsOneWidget);
    });

    testWidgets('should render FilterChips', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FilterChips), findsOneWidget);
    });

    testWidgets('should show loading indicator for GalleryStarting state', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(const GalleryStarting());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator for GalleryLoading state', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(const GalleryLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render grid when in GalleryLoaded state', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          isSelectionMode: false,
          selectedFileIds: const {},
          hasNext: true,
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle empty files list', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: const [],
          groupedFiles: const [],
          isSelectionMode: false,
          selectedFileIds: const {},
          hasNext: false,
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should not show FAB when not in selection mode', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          isSelectionMode: false,
          selectedFileIds: const {},
          hasNext: true,
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should show FAB when in selection mode with files selected', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
          hasNext: true,
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should not show FAB when in selection mode but no files selected', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          isSelectionMode: true,
          selectedFileIds: const {},
          hasNext: true,
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should handle GalleryLoadingMore state', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoadingMore(
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          isSelectionMode: false,
          selectedFileIds: const {},
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should pass correct filter to FilterChips', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.stream)
          .thenAnswer((_) => Stream.value(GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
        filter: FileFilter.images,
      )));
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          isSelectionMode: false,
          selectedFileIds: const {},
          hasNext: true,
          currentPage: 0,
          filter: FileFilter.images,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      final filterChips = tester.widget<FilterChips>(find.byType(FilterChips));
      expect(filterChips.selectedFilter, FileFilter.images);
    });

    testWidgets('should pass selection mode state to GalleryHeader', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          isSelectionMode: true,
          selectedFileIds: {'file-1', 'file-2'},
          hasNext: true,
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final header = tester.widget<GalleryHeader>(find.byType(GalleryHeader));
      expect(header.isSelectionMode, true);
      expect(header.selectedCount, 2);
    });

    testWidgets('should handle many files', (tester) async {
      // Arrange
      final manyFiles = List.generate(
        100,
        (index) => GalleryFile(
          id: 'file-$index',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      );

      when(() => mockGalleryBloc.state).thenReturn(
        GalleryLoaded(
          files: manyFiles,
          groupedFiles: groupTestFiles(manyFiles),
          isSelectionMode: false,
          selectedFileIds: const {},
          hasNext: true,
          currentPage: 0,
          filter: FileFilter.all,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
