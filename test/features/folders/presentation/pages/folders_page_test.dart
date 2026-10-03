import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/pages/folders_page.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_album_card.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/folder_card.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockFolderBloc extends Mock implements FolderBloc {}

void main() {
  late MockFolderBloc mockFolderBloc;

  setUp(() {
    mockFolderBloc = MockFolderBloc();
    when(() => mockFolderBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockFolderBloc.state).thenReturn(const FolderStarting());
  });

  Future<void> pumpPage(WidgetTester tester, FolderState state) async {
    setUpCustomScreenSize(tester, 390, 1400);
    when(() => mockFolderBloc.state).thenReturn(state);
    await tester.pumpWidget(makeTestableWidget(
      BlocProvider<FolderBloc>.value(value: mockFolderBloc, child: const FoldersPage()),
    ));
  }

  final albums = [
    TestFolders.album(id: '1', name: 'Japan'),
    TestFolders.album(id: '2', name: 'Family'),
    TestFolders.album(id: '3', name: 'Japan 2019'),
  ];

  group('FoldersPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the Albums header with a New button', (tester) async {
      // Arrange & Act
      await pumpPage(tester, FolderLoaded(folders: albums));

      // Assert
      expect(find.text('Albums'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Search albums'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should list every album followed by the create card', (tester) async {
      // Arrange & Act
      await pumpPage(tester, FolderLoaded(folders: albums));

      // Assert
      expect(find.byType(FolderCard), findsNWidgets(3));
      expect(find.byType(CreateAlbumCard), findsOneWidget);
    });

    testWidgets('should filter albums by name while searching', (tester) async {
      // Arrange
      await pumpPage(tester, FolderLoaded(folders: albums));

      // Act
      await tester.enterText(find.byType(TextField), 'jap');
      await tester.pump();

      // Assert
      expect(find.byType(FolderCard), findsNWidgets(2));
      expect(find.text('Family'), findsNothing);
      expect(find.byType(CreateAlbumCard), findsNothing);
    });

    testWidgets('should explain when no album matches', (tester) async {
      // Arrange
      await pumpPage(tester, FolderLoaded(folders: albums));

      // Act
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      // Assert
      expect(find.text('No album matches “zzz”'), findsOneWidget);
    });

    testWidgets('should open the new album sheet from the header', (tester) async {
      // Arrange
      await pumpPage(tester, FolderLoaded(folders: albums));

      // Act
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CreateFolderModal), findsOneWidget);
    });

    // ==================== LOADING & EMPTY STATE TESTS ====================

    testWidgets('should show a spinner while loading', (tester) async {
      // Arrange & Act
      await pumpPage(tester, const FolderLoading());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show the empty state with a create action', (tester) async {
      // Arrange & Act
      await pumpPage(tester, const FolderLoaded(folders: []));

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text("You don't have albums"), findsOneWidget);
      expect(find.text('Create album'), findsOneWidget);
    });

    testWidgets('should show the operation message while creating', (tester) async {
      // Arrange & Act
      await pumpPage(tester, const FolderOperationLoading(operation: 'create'));

      // Assert
      expect(find.text('Creating album...'), findsOneWidget);
    });
  });
}
