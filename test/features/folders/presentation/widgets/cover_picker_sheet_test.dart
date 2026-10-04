import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/folders/domain/entities/album_cover.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_target.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_covers.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/cover_picker/cover_picker_cubit.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/cover_picker/cover_picker_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/cover_picker_sheet.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockCoverPickerCubit extends MockCubit<CoverPickerState> implements CoverPickerCubit {}

void main() {
  late MockCoverPickerCubit cubit;

  setUp(() {
    cubit = MockCoverPickerCubit();
    when(() => cubit.load(any())).thenAnswer((_) async {});
    when(() => cubit.save()).thenAnswer((_) async {});
  });

  AlbumCover cover(String id, int position) =>
      AlbumCover(fileId: id, position: position, sourceFolderId: 'x', sourceFolderName: 'X');

  CoverTarget target(String id, String name, List<String> covers, {int depth = 0, bool direct = false}) => CoverTarget(
        folderId: id,
        name: name,
        depth: depth,
        containsDirectly: direct,
        covers: [for (var i = 0; i < covers.length; i++) cover(covers[i], i)],
      );

  final targets = [
    target('a1', 'Vacaciones 2024', ['p1', 'c1']),
    target('a2', 'Playa', ['c1', 'c2', 'c3'], depth: 1),
    target('a3', 'Atardeceres', [], depth: 2, direct: true),
  ];

  CoverPickerState ready({Set<String> checked = const {'a1'}, Map<String, List<String>> replacements = const {}}) =>
      CoverPickerState(
        status: CoverPickerStatus.ready,
        fileIds: const ['p1'],
        targets: targets,
        checked: checked,
        replacements: replacements,
      );

  Future<void> pump(WidgetTester tester, CoverPickerState state) {
    when(() => cubit.state).thenReturn(state);
    setUpCustomScreenSize(tester, 390, 1600);
    return tester.pumpWidget(makeTestableWidget(BlocProvider<CoverPickerCubit>.value(
      value: cubit,
      child: const Scaffold(body: SingleChildScrollView(child: CoverPickerSheet())),
    )));
  }

  AppButton saveButton(WidgetTester tester) => tester.widget<AppButton>(find.byType(AppButton).first);

  group('CoverPickerSheet', () {
    testWidgets('should list the tree from the root, indented by level', (tester) async {
      // Arrange & Act
      await pump(tester, ready());

      // Assert
      expect(find.text('Use as cover'), findsOneWidget);
      final x1 = tester.getTopLeft(find.text('Vacaciones 2024')).dx;
      final x2 = tester.getTopLeft(find.text('Playa')).dx;
      final x3 = tester.getTopLeft(find.text('Atardeceres')).dx;
      expect(x2 - x1, 22);
      expect(x3 - x2, 22);
      expect(find.text('The photo is here'), findsOneWidget);
      expect(find.text("Only the photo's album and the albums that contain it are shown."), findsOneWidget);
    });

    testWidgets('should describe each album with its tick', (tester) async {
      // Arrange & Act
      await pump(tester, ready());

      // Assert
      expect(find.text('Already a cover · untick to remove it'), findsOneWidget);
      expect(find.text('3 of 3 covers'), findsOneWidget);
      expect(find.text('0 of 3 covers'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Vacaciones 2024')),
        containsSemantics(hasCheckedState: true, isChecked: true),
      );
    });

    testWidgets('should tick an album when tapping its row', (tester) async {
      // Arrange
      await pump(tester, ready());

      // Act
      await tester.tap(find.text('Atardeceres'));

      // Assert
      verify(() => cubit.toggle('a3')).called(1);
    });

    testWidgets('should show the pending changes and the save count', (tester) async {
      // Arrange & Act
      await pump(tester, ready(checked: {'a3'}));

      // Assert
      expect(find.text('Will be removed from the cover'), findsOneWidget);
      expect(find.text('Will be added · 1 of 3'), findsOneWidget);
      expect(saveButton(tester).label, 'Save · 2 changes');
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('should ask which cover to replace in a full album and wait to save', (tester) async {
      // Arrange
      await pump(tester, ready(checked: {'a1', 'a2'}));

      // Act
      await tester.tap(find.bySemanticsLabel('Replace cover 2 of Playa'));

      // Assert
      expect(find.text('Full · choose which to replace'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);
      verify(() => cubit.chooseReplacement('a2', 'c2')).called(1);
    });

    testWidgets('should mark the chosen cover to replace and allow saving', (tester) async {
      // Arrange & Act
      await pump(tester, ready(checked: {'a1', 'a2'}, replacements: {'a2': ['c2']}));

      // Assert
      expect(find.text('Replace'), findsOneWidget);
      expect(find.text('Will be added · 3 of 3'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Replace cover 2 of Playa')),
        containsSemantics(isChecked: true, isInMutuallyExclusiveGroup: true),
      );
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('should save', (tester) async {
      // Arrange
      await pump(tester, ready(checked: {'a3'}));

      // Act
      await tester.tap(find.text('Save · 2 changes'));

      // Assert
      verify(() => cubit.save()).called(1);
    });

    testWidgets('should disable saving without changes', (tester) async {
      await pump(tester, ready());
      expect(saveButton(tester).onPressed, isNull);
    });

    // ==================== ACCESSIBILITY TESTS ====================

    testWidgets('should meet the tap target and label guidelines', (tester) async {
      // Arrange
      final handle = tester.ensureSemantics();

      // Act
      await pump(tester, ready(checked: {'a1', 'a2'}));

      // Assert
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(
        tester.getSemantics(find.text('Playa')),
        containsSemantics(label: 'Playa, Full · choose which to replace', hasCheckedState: true, isChecked: true),
      );
      handle.dispose();
    });

    testWidgets('should take the colors of a changed row from the dark palette', (tester) async {
      // Arrange
      when(() => cubit.state).thenReturn(ready(checked: {'a3'}));
      setUpCustomScreenSize(tester, 390, 1600);

      // Act
      await tester.pumpWidget(makeTestableWidget(
        BlocProvider<CoverPickerCubit>.value(
          value: cubit,
          child: const Scaffold(body: SingleChildScrollView(child: CoverPickerSheet())),
        ),
        themeMode: ThemeMode.dark,
      ));

      // Assert
      const p = AppPalette.dark;
      final cards = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      final decorations = cards.map((c) => c.decoration as BoxDecoration).toList();
      expect(decorations.map((d) => d.color), [
        p.accentSoft.withValues(alpha: 0.5), // root: will remove
        p.surface, // beach: no change
        p.accentSoft.withValues(alpha: 0.5), // sunsets: will add
      ]);
      expect((decorations.first.border! as Border).top.color, p.accent);
      final status = tester.widget<Text>(find.text('Will be removed from the cover'));
      expect(status.style!.color, p.dangerInk);
    });

    testWidgets('should say the photos are here for several photos', (tester) async {
      // Arrange & Act
      await pump(tester, CoverPickerState(
        status: CoverPickerStatus.ready,
        fileIds: const ['p2', 'p3'],
        targets: targets,
      ));

      // Assert
      expect(find.text('The photos are here'), findsOneWidget);
    });

    group('show', () {
      late StreamController<CoverPickerState> states;

      setUp(() {
        states = StreamController<CoverPickerState>();
        whenListen(cubit, states.stream, initialState: const CoverPickerState(fileIds: ['p1']));
        sl.registerFactory<CoverPickerCubit>(() => cubit);
      });

      tearDown(() {
        states.close();
        sl.unregister<CoverPickerCubit>();
      });

      Future<CoverPickerResult? Function()> open(WidgetTester tester) async {
        CoverPickerResult? result;
        await tester.pumpWidget(makeTestableWidget(Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result = await CoverPickerSheet.show(context, ['p1']),
              child: const Text('open'),
            ),
          ),
        )));
        return () => result;
      }

      testWidgets('should close with the saved covers', (tester) async {
        // Arrange
        final result = await open(tester);
        await tester.tap(find.text('open'));
        await tester.pump(const Duration(milliseconds: 500));

        // Act
        states.add(ready(checked: {'a3'}).copyWith(
          status: CoverPickerStatus.saved,
          savedFolders: const [FolderCovers(folderId: 'a3', covers: [])],
        ));
        await tester.pumpAndSettle();

        // Assert
        final saved = result();
        expect(saved, isA<CoversSaved>().having((r) => r.changedAlbums, 'albums', 2));
        verify(() => cubit.load(['p1'])).called(1);
      });

      testWidgets('should close when the photos share no album', (tester) async {
        // Arrange
        final result = await open(tester);
        await tester.tap(find.text('open'));
        await tester.pump(const Duration(milliseconds: 500));

        // Act
        states.add(const CoverPickerState(status: CoverPickerStatus.noSharedAlbum, fileIds: ['p1', 'p2']));
        await tester.pumpAndSettle();

        // Assert
        expect(result(), isA<NoSharedAlbum>());
      });
    });
  });
}
