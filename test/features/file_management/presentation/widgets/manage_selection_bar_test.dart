import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_selection_bar.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockFileManagementBloc extends Mock implements FileManagementBloc {}

class MockManageFolderBloc extends Mock implements ManageFolderBloc {}

class FakeFileManagementEvent extends Fake implements FileManagementEvent {}

void main() {
  late MockFileManagementBloc fileBloc;
  late MockManageFolderBloc folderBloc;
  late StreamController<FileManagementState> states;
  late int finished;

  setUpAll(() => registerFallbackValue(FakeFileManagementEvent()));

  setUp(() {
    finished = 0;
    states = StreamController<FileManagementState>.broadcast();
    fileBloc = MockFileManagementBloc();
    when(() => fileBloc.state).thenReturn(const FileManagementStarting());
    when(() => fileBloc.stream).thenAnswer((_) => states.stream);
    folderBloc = MockManageFolderBloc();
    when(() => folderBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => folderBloc.state).thenReturn(const ManageFoldersLoaded(folders: []));
  });

  tearDown(() => states.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pump(WidgetTester tester, {List<String> ids = const ['a', 'b', 'c'], int sizeBytes = 0}) {
    setUpCustomScreenSize(tester, 390, 1200);
    return tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<FileManagementBloc>.value(value: fileBloc),
        BlocProvider<ManageFolderBloc>.value(value: folderBloc),
      ],
      child: Scaffold(
        bottomNavigationBar: ManageSelectionBar(
          fileIds: ids,
          selectedSizeBytes: sizeBytes,
          onFinished: () => finished++,
        ),
      ),
    ));
  }

  Future<void> confirmDialog(WidgetTester tester) async {
    await settle(tester);
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.byType(AppButton)).last);
    await settle(tester);
  }

  ManageAction dispatchedAction() {
    final event = verify(() => fileBloc.add(captureAny())).captured.single as ManagedFilesRequested;
    return event.action;
  }

  group('ManageSelectionBar', () {
    testWidgets('should show the count and the four actions', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      expect(find.text('3 photos'), findsOneWidget);
      for (final label in ['Save', 'To album', 'Free up', 'Delete']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('should open the sheet with "save and free" preselected', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      await tester.tap(find.text('Save'));
      await settle(tester);

      // Assert
      final sheet = tester.widget<ManageFileModal>(find.byType(ManageFileModal));
      expect(sheet.initialOption, ManageOption.saveAndFree);
      expect(sheet.fileIds, ['a', 'b', 'c']);
    });

    testWidgets('should pass the selected size to the sheet', (tester) async {
      // Arrange
      await pump(tester, sizeBytes: 5 * 1024 * 1024);

      // Act
      await tester.tap(find.text('Save'));
      await settle(tester);

      // Assert
      expect(tester.widget<ManageFileModal>(find.byType(ManageFileModal)).totalSizeBytes, 5 * 1024 * 1024);
      expect(find.text('3 photos · 5 MB'), findsOneWidget);
    });

    testWidgets('should open the sheet with the album option preselected', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      await tester.tap(find.text('To album'));
      await settle(tester);

      // Assert
      expect(tester.widget<ManageFileModal>(find.byType(ManageFileModal)).initialOption, ManageOption.album);
    });

    testWidgets('should free up space after confirming', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      await tester.tap(find.text('Free up'));
      await confirmDialog(tester);

      // Assert
      expect(dispatchedAction(), const ManageAction(serverAction: ServerAction.save, keepOnDevice: false));
    });

    testWidgets('should delete after a destructive confirmation', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      await tester.tap(find.text('Delete'));
      await confirmDialog(tester);

      // Assert
      expect(dispatchedAction(), const ManageAction(serverAction: ServerAction.delete, keepOnDevice: false));
    });

    testWidgets('should finish the selection when its action succeeds', (tester) async {
      // Arrange
      await pump(tester);
      await tester.tap(find.text('Free up'));
      await confirmDialog(tester);

      // Act
      states.add(const FileManagementSuccess(message: 'Done', processedCount: 3));
      await settle(tester);

      // Assert
      expect(finished, 1);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('should disable the actions without selected files', (tester) async {
      // Arrange
      await pump(tester, ids: const []);

      // Act
      await tester.tap(find.text('Delete'));
      await settle(tester);

      // Assert
      expect(find.byType(AppDialog), findsNothing);
    });
  });
}
