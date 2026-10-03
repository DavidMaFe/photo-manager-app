import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockFileManagementBloc extends Mock implements FileManagementBloc {}

class MockManageFolderBloc extends Mock implements ManageFolderBloc {}

class FakeFileManagementEvent extends Fake implements FileManagementEvent {}

void main() {
  late MockFileManagementBloc fileBloc;
  late MockManageFolderBloc folderBloc;
  late StreamController<FileManagementState> states;

  setUpAll(() => registerFallbackValue(FakeFileManagementEvent()));

  setUp(() {
    states = StreamController<FileManagementState>.broadcast();
    fileBloc = MockFileManagementBloc();
    when(() => fileBloc.state).thenReturn(const FileManagementStarting());
    when(() => fileBloc.stream).thenAnswer((_) => states.stream);

    folderBloc = MockManageFolderBloc();
    when(() => folderBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => folderBloc.state).thenReturn(ManageFoldersLoaded(folders: [
      ManageFolder(id: 'f1', name: 'Japan', fileCount: 10, createdAt: DateTime(2024)),
      ManageFolder(id: 'f2', name: 'Family', fileCount: 3, createdAt: DateTime(2024)),
    ]));
  });

  tearDown(() => states.close());

  /// Viewer thumbnails keep loading in tests, so pumpAndSettle never settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> open(WidgetTester tester, {List<String> ids = const ['a', 'b'], ManageOption option = ManageOption.saveAndFree}) async {
    setUpCustomScreenSize(tester, 390, 1200);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<FileManagementBloc>.value(value: fileBloc),
        BlocProvider<ManageFolderBloc>.value(value: folderBloc),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => ManageFileModal.show(context, fileIds: ids, initialOption: option),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await settle(tester);
  }

  ManageAction dispatchedAction() {
    final event = verify(() => fileBloc.add(captureAny())).captured.single as ManagedFilesRequested;
    return event.action;
  }

  AppButton primary(WidgetTester tester) => tester.widget<AppButton>(find.byType(AppButton).first);

  group('ManageFileModal', () {
    // ==================== HEADER & OPTIONS TESTS ====================

    testWidgets('should ask about the selected photos', (tester) async {
      // Arrange & Act
      await open(tester);

      // Assert
      expect(find.text('What should we do with these 2 photos?'), findsOneWidget);
      expect(find.text('2 photos selected'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('should use the singular question for one photo', (tester) async {
      // Arrange & Act
      await open(tester, ids: const ['a']);

      // Assert
      expect(find.text('What should we do with this photo?'), findsOneWidget);
    });

    testWidgets('should save and free up space by default', (tester) async {
      // Arrange
      await open(tester);
      expect(primary(tester).label, 'Save and free up space');

      // Act
      await tester.tap(find.byType(AppButton).first);

      // Assert
      expect(dispatchedAction(), const ManageAction(serverAction: ServerAction.save, keepOnDevice: false));
    });

    testWidgets('should save and keep on the phone', (tester) async {
      // Arrange
      await open(tester);

      // Act
      await tester.tap(find.text('Save and keep on the phone'));
      await tester.pump();
      await tester.tap(find.byType(AppButton).first);

      // Assert
      expect(primary(tester).label, 'Save');
      expect(dispatchedAction(), const ManageAction(serverAction: ServerAction.save, keepOnDevice: true));
    });

    // ==================== ALBUM TESTS ====================

    testWidgets('should require an album before saving to one', (tester) async {
      // Arrange & Act
      await open(tester, option: ManageOption.album);

      // Assert
      expect(primary(tester).label, 'Choose an album');
      expect(primary(tester).onPressed, isNull);
      expect(find.text('Japan'), findsOneWidget);
    });

    testWidgets('should save to the chosen album and remove from the phone', (tester) async {
      // Arrange
      await open(tester, option: ManageOption.album);

      // Act
      await tester.tap(find.text('Japan'));
      await tester.pump();
      await tester.tap(find.byType(AppButton).first);

      // Assert
      expect(primary(tester).label, 'Save to Japan');
      expect(
        dispatchedAction(),
        const ManageAction(serverAction: ServerAction.folder, folderId: 'f1', keepOnDevice: false),
      );
    });

    testWidgets('should keep the phone copy when the switch is off', (tester) async {
      // Arrange
      await open(tester, option: ManageOption.album);
      await tester.tap(find.text('Family'));
      await tester.pump();

      // Act
      await tester.tap(find.bySemanticsLabel('Remove from the phone afterwards'));
      await tester.pump();
      await tester.tap(find.byType(AppButton).first);

      // Assert
      expect(dispatchedAction().keepOnDevice, isTrue);
    });

    testWidgets('should create a new album from the inline field', (tester) async {
      // Arrange
      await open(tester, option: ManageOption.album);

      // Act
      await tester.tap(find.text('New'));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'Kyoto');
      await tester.pump();
      await tester.tap(find.byType(AppButton).first);

      // Assert
      expect(primary(tester).label, 'Save to Kyoto');
      expect(
        dispatchedAction(),
        const ManageAction(serverAction: ServerAction.newFolder, folderName: 'Kyoto', keepOnDevice: false),
      );
    });

    // ==================== DELETE TESTS ====================

    testWidgets('should confirm before deleting everywhere', (tester) async {
      // Arrange
      await open(tester);

      // Act
      await tester.tap(find.text('Delete everywhere'));
      await settle(tester);
      expect(find.byType(AppDialog), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.byType(AppButton)).last);
      await settle(tester);

      // Assert
      expect(dispatchedAction(), const ManageAction(serverAction: ServerAction.delete, keepOnDevice: false));
    });

    // ==================== RESULT TESTS ====================

    testWidgets('should close with a snackbar after a successful action', (tester) async {
      // Arrange
      await open(tester);
      await tester.tap(find.byType(AppButton).first);

      // Act
      states.add(const FileManagementSuccess(message: 'Saved', processedCount: 2));
      await settle(tester);

      // Assert
      expect(find.byType(ManageFileModal), findsNothing);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('should ignore results of actions it did not start', (tester) async {
      // Arrange
      await open(tester);

      // Act
      states.add(const FileManagementSuccess(message: 'Other', processedCount: 1));
      await settle(tester);

      // Assert
      expect(find.byType(ManageFileModal), findsOneWidget);
    });

    testWidgets('should show the loading state on the primary button', (tester) async {
      // Arrange
      when(() => fileBloc.state).thenReturn(const FileManagementLoading());

      // Act
      await open(tester);

      // Assert
      expect(primary(tester).loading, isTrue);
    });
  });
}
