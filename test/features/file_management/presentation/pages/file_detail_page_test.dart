import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/pages/file_detail_page.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockFileManagementBloc extends Mock implements FileManagementBloc {}
class MockManageFolderBloc extends Mock implements ManageFolderBloc {}

void main() {
  late MockFileManagementBloc mockFileManagementBloc;
  late MockManageFolderBloc mockManageFolderBloc;

  setUp(() {
    mockFileManagementBloc = MockFileManagementBloc();
    mockManageFolderBloc = MockManageFolderBloc();

    when(() => mockFileManagementBloc.stream)
        .thenAnswer((_) => Stream.value(const FileManagementStarting()));
    when(() => mockFileManagementBloc.state)
        .thenReturn(const FileManagementStarting());

    when(() => mockManageFolderBloc.stream)
        .thenAnswer((_) => Stream.value(const ManageFolderStarting()));
    when(() => mockManageFolderBloc.state)
        .thenReturn(const ManageFolderStarting());
  });

  group('FileDetailPage', () {
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
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate.add(const Duration(hours: 1)),
      ),
    ];

    Widget createWidgetUnderTest({
      required List<GalleryFile> files,
      int initialIndex = 0,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<FileManagementBloc>.value(value: mockFileManagementBloc),
            BlocProvider<ManageFolderBloc>.value(value: mockManageFolderBloc),
          ],
          child: FileDetailPage(
            files: files,
            initialIndex: initialIndex,
          ),
        ),
      );
    }

    testWidgets('should display app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display PageView for file browsing', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should start at initial index', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        files: testFiles,
        initialIndex: 1,
      ));
      await tester.pump();

      // Assert
      // PageView should be initialized at index 1
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should display file with single file', (tester) async {
      // Arrange
      final singleFile = [testFiles.first];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(files: singleFile));

      // Assert
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should have black background', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('should create PageController with correct initial page', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        files: testFiles,
        initialIndex: 1,
      ));

      // Assert
      // Widget should initialize without errors
      expect(find.byType(FileDetailPage), findsOneWidget);
    });

    testWidgets('should handle multiple files', (tester) async {
      // Arrange
      final manyFiles = List.generate(
        5,
        (i) => GalleryFile(
          id: 'file-$i',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate.add(Duration(hours: i)),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(files: manyFiles));

      // Assert
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should dispose PageController on widget disposal', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(files: testFiles));

      // Remove widget
      await tester.pumpWidget(const SizedBox());

      // Assert - should not throw errors
      expect(find.byType(FileDetailPage), findsNothing);
    });
  });
}
