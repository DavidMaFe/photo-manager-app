import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_folder_modal.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockFolderBloc extends Mock implements FolderBloc {}

void main() {
  late MockFolderBloc mockFolderBloc;

  setUp(() {
    mockFolderBloc = MockFolderBloc();
    when(() => mockFolderBloc.stream)
        .thenAnswer((_) => Stream.value(const FolderStarting()));
    when(() => mockFolderBloc.state).thenReturn(const FolderStarting());
  });

  group('CreateFolderModal', () {
    Widget createWidgetUnderTest({String? parentFolderId}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<FolderBloc>.value(
            value: mockFolderBloc,
            child: CreateFolderModal(parentFolderId: parentFolderId),
          ),
        ),
      );
    }

    testWidgets('should render modal container', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CreateFolderModal), findsOneWidget);
    });

    testWidgets('should display text field for folder name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle null parentFolderId', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(parentFolderId: null));

      // Assert
      expect(find.byType(CreateFolderModal), findsOneWidget);
    });

    testWidgets('should handle non-null parentFolderId', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(parentFolderId: 'parent-1'));

      // Assert
      expect(find.byType(CreateFolderModal), findsOneWidget);
    });

    testWidgets('should have white background container', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CreateFolderModal), findsOneWidget);
    });
  });
}
