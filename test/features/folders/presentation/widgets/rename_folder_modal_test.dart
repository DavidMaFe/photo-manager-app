import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/rename_folder_modal.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockFolderBloc extends Mock implements FolderBloc {}

class FakeFolderEvent extends Fake implements FolderEvent {}

void main() {
  late MockFolderBloc bloc;

  setUpAll(() => registerFallbackValue(FakeFolderEvent()));

  setUp(() {
    bloc = MockFolderBloc();
    when(() => bloc.state).thenReturn(const FolderStarting());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Future<void> openSheet(WidgetTester tester, Folder folder) async {
    await tester.pumpWidget(makeTestableWidget(BlocProvider<FolderBloc>.value(
      value: bloc,
      child: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => RenameFolderModal.show(context, folder),
            child: const Text('open'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('RenameFolderModal', () {
    testWidgets('should prefill the current name', (tester) async {
      // Arrange & Act
      await openSheet(tester, TestFolders.album(name: 'Vacation'));

      // Assert
      expect(find.text('Rename album'), findsOneWidget);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller!.text, 'Vacation');
    });

    testWidgets('should handle unicode names', (tester) async {
      // Arrange & Act
      await openSheet(tester, TestFolders.album(name: '日本 🎌'));

      // Assert
      expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, '日本 🎌');
    });

    testWidgets('should reject names over 100 characters', (tester) async {
      // Arrange
      await openSheet(tester, TestFolders.album());
      final field = tester.widget<TextFormField>(find.byType(TextFormField));

      // Act
      final result = field.validator!('a' * 101);

      // Assert
      expect(result, 'Max 100 characters');
    });

    testWidgets('should require a name', (tester) async {
      // Arrange
      await openSheet(tester, TestFolders.album());
      await tester.enterText(find.byType(TextFormField), '   ');

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(find.text('Album name is required'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should rename and close', (tester) async {
      // Arrange
      await openSheet(tester, TestFolders.album(id: 'folder-9'));
      await tester.enterText(find.byType(TextFormField), 'Holidays');

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => bloc.add(const RenameFolderRequested(folderId: 'folder-9', newName: 'Holidays'))).called(1);
      expect(find.byType(RenameFolderModal), findsNothing);
    });
  });
}
