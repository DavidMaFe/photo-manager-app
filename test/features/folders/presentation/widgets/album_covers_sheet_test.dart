import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/features/folders/domain/entities/album_cover.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/album_covers/album_covers_cubit.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/album_covers/album_covers_state.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_covers_sheet.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_mosaic.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockAlbumCoversCubit extends MockCubit<AlbumCoversState> implements AlbumCoversCubit {}

void main() {
  late MockAlbumCoversCubit cubit;

  setUp(() {
    cubit = MockAlbumCoversCubit();
    when(() => cubit.load(any())).thenAnswer((_) async {});
    when(() => cubit.save()).thenAnswer((_) async {});
  });

  final folder = TestFolders.album(id: 'a2', name: 'Playa', fallbackCoverFileIds: ['r1', 'r2']);
  const own = AlbumCover(fileId: 'c1', position: 0, sourceFolderId: 'a2', sourceFolderName: 'Playa');
  const fromSub = AlbumCover(
    fileId: 'c2',
    position: 1,
    sourceFolderId: 'a3',
    sourceFolderName: 'Atardeceres',
    sourceFolderPath: ['Atardeceres'],
  );

  AlbumCoversState ready(List<AlbumCover> covers, {(AlbumCover, int)? lastRemoved}) => AlbumCoversState(
        status: AlbumCoversStatus.ready,
        folderId: 'a2',
        original: covers,
        covers: covers,
        lastRemoved: lastRemoved,
      );

  Future<void> pump(WidgetTester tester, AlbumCoversState state) {
    when(() => cubit.state).thenReturn(state);
    setUpCustomScreenSize(tester, 390, 1400);
    return tester.pumpWidget(makeTestableWidget(BlocProvider<AlbumCoversCubit>.value(
      value: cubit,
      child: Scaffold(body: SingleChildScrollView(child: AlbumCoversSheet(folder: folder))),
    )));
  }

  group('AlbumCoversSheet', () {
    testWidgets('should list the covers in order with where they come from', (tester) async {
      // Arrange & Act
      await pump(tester, ready([own, fromSub]));

      // Assert
      expect(find.text('Cover of Playa'), findsOneWidget);
      expect(find.text('2 of 3 photos · drag to change the order'), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('From this album'), findsOneWidget);
      expect(find.text('From Atardeceres'), findsOneWidget);
      expect(find.text('How it looks in Albums'), findsOneWidget);
      expect(tester.widget<AlbumMosaic>(find.byType(AlbumMosaic)).fileIds, ['c1', 'c2']);
    });

    testWidgets('should remove a cover from its button', (tester) async {
      // Arrange
      await pump(tester, ready([own, fromSub]));

      // Act
      await tester.tap(find.byTooltip('Remove from cover').last);

      // Assert
      verify(() => cubit.remove('c2')).called(1);
    });

    testWidgets('should offer to undo the last removal', (tester) async {
      // Arrange
      await pump(tester, ready([own], lastRemoved: (fromSub, 1)));

      // Act
      await tester.tap(find.text('Undo'));

      // Assert
      expect(find.text('Removed from the cover'), findsOneWidget);
      verify(() => cubit.undoRemove()).called(1);
    });

    testWidgets('should move covers with the accessibility actions', (tester) async {
      // Arrange
      final handle = tester.ensureSemantics();
      await pump(tester, ready([own, fromSub]));

      // Act
      final semantics = tester.getSemantics(find.text('Main'));
      final down = semantics.getSemanticsData().customSemanticsActionIds!.map(CustomSemanticsAction.getAction);

      // Assert
      expect(down.map((a) => a!.label), contains('Move down'));
      handle.dispose();
    });

    testWidgets('should dim the recent photos while the covers are automatic', (tester) async {
      // Arrange & Act
      await pump(tester, ready(const []));

      // Assert
      expect(find.text('Automatic · recent photos'), findsOneWidget);
      expect(find.text('Automatic'), findsOneWidget);
      expect(tester.widget<AlbumMosaic>(find.byType(AlbumMosaic)).fileIds, ['r1', 'r2']);
      expect(
        tester.widget<Opacity>(find.ancestor(of: find.byType(AlbumMosaic), matching: find.byType(Opacity))).opacity,
        0.5,
      );
    });

    testWidgets('should save with Done', (tester) async {
      // Arrange
      await pump(tester, ready([own]));

      // Act
      await tester.tap(find.text('Done'));

      // Assert
      verify(() => cubit.save()).called(1);
    });

    testWidgets('should retry loading after an error', (tester) async {
      // Arrange
      await pump(tester, const AlbumCoversState(status: AlbumCoversStatus.failure, folderId: 'a2', failure: NetworkFailure()));

      // Act
      await tester.tap(find.text('Retry'));

      // Assert
      verify(() => cubit.load('a2')).called(1);
    });

    testWidgets('should show a loading indicator first', (tester) async {
      await pump(tester, const AlbumCoversState(folderId: 'a2'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should close telling whether the covers changed', (tester) async {
      // Arrange
      final states = StreamController<AlbumCoversState>();
      addTearDown(states.close);
      whenListen(cubit, states.stream, initialState: ready([own]));
      sl.registerFactory<AlbumCoversCubit>(() => cubit);
      addTearDown(() => sl.unregister<AlbumCoversCubit>());
      bool? result;
      await tester.pumpWidget(makeTestableWidget(Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => result = await AlbumCoversSheet.show(context, folder),
            child: const Text('open'),
          ),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Act
      states.add(ready([own]).copyWith(status: AlbumCoversStatus.saved, changesSaved: true));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isTrue);
      expect(find.byType(AlbumCoversSheet), findsNothing);
      verify(() => cubit.load('a2')).called(1);
    });

    testWidgets('should meet the tap target and label guidelines', (tester) async {
      // Arrange
      final handle = tester.ensureSemantics();

      // Act
      await pump(tester, ready([own, fromSub], lastRemoved: (fromSub, 2)));

      // Assert
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('should use the drag handle for each cover', (tester) async {
      await pump(tester, ready([own, fromSub]));
      expect(find.byIcon(Symbols.drag_indicator_rounded), findsNWidgets(2));
    });
  });
}
