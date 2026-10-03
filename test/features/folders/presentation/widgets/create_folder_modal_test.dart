import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';

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

  Future<void> openSheet(WidgetTester tester, {String? parentFolderId}) async {
    await tester.pumpWidget(makeTestableWidget(BlocProvider<FolderBloc>.value(
      value: bloc,
      child: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => CreateFolderModal.show(context, parentFolderId: parentFolderId),
            child: const Text('open'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('CreateFolderModal', () {
    testWidgets('should show the new album title and field', (tester) async {
      // Arrange & Act
      await openSheet(tester);

      // Assert
      expect(find.text('New album'), findsOneWidget);
      expect(find.text('Album name'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should use the sub-album title inside an album', (tester) async {
      // Arrange & Act
      await openSheet(tester, parentFolderId: 'parent-1');

      // Assert
      expect(find.text('New sub-album'), findsOneWidget);
    });

    testWidgets('should require a name', (tester) async {
      // Arrange
      await openSheet(tester);

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(find.text('Album name is required'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should create the album with the trimmed name and close', (tester) async {
      // Arrange
      await openSheet(tester, parentFolderId: 'parent-1');
      await tester.enterText(find.byType(TextFormField), '  Japan  ');

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => bloc.add(const CreateFolderRequested(name: 'Japan', parentFolderId: 'parent-1'))).called(1);
      expect(find.byType(CreateFolderModal), findsNothing);
    });
  });
}
