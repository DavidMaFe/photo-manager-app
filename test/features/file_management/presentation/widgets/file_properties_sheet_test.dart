import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_properties_sheet.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockFileInfoBloc extends MockBloc<FileInfoEvent, FileInfoState> implements FileInfoBloc {}

void main() {
  late MockFileInfoBloc bloc;

  setUp(() {
    bloc = MockFileInfoBloc();
    when(() => bloc.state).thenReturn(const FileInfoLoading());
  });

  final video = GalleryFile(
    id: 'abc-123',
    type: FileType.video,
    status: FileStatus.pending,
    durationSeconds: 75,
    capturedAt: DateTime(2024, 1, 15, 10, 42),
  );

  Future<void> pump(WidgetTester tester, GalleryFile file, {FileInfoState? state}) {
    if (state != null) when(() => bloc.state).thenReturn(state);
    setUpCustomScreenSize(tester, 390, 1400);
    return tester.pumpWidget(makeTestableWidget(BlocProvider<FileInfoBloc>.value(
      value: bloc,
      child: Scaffold(body: SingleChildScrollView(child: FilePropertiesSheet(file: file))),
    )));
  }

  final fullInfo = FileInfo(
    id: 'abc-123',
    originalFilename: 'IMG_2041.MOV',
    type: FileType.video,
    status: FileStatus.pending,
    width: 1920,
    height: 1080,
    durationSeconds: 75,
    sizeBytes: 412 * 1024 * 1024,
    capturedAt: DateTime(2024, 1, 15, 10, 42),
    uploadedAt: DateTime(2024, 1, 16, 3, 5),
    folderId: '7',
    folderName: 'Japan',
    deviceId: '2',
    deviceName: 'Pixel 8',
  );

  group('FilePropertiesSheet', () {
    testWidgets('should list status, full capture date, duration and id', (tester) async {
      // Arrange & Act
      await pump(tester, video);

      // Assert
      final chip = tester.widget<StatusChip>(find.byType(StatusChip));
      expect(chip.label, 'To review');
      expect(chip.variant, StatusChipVariant.review);
      expect(find.text('Monday, January 15, 2024, 10:42'), findsOneWidget);
      expect(find.text('1:15'), findsOneWidget);
      expect(find.text('abc-123'), findsOneWidget);
    });

    testWidgets('should mark managed photos as backed up without duration', (tester) async {
      // Arrange & Act
      await pump(tester, GalleryFile(
        id: 'p1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: DateTime(2024, 1, 15),
      ));

      // Assert
      expect(tester.widget<StatusChip>(find.byType(StatusChip)).variant, StatusChipVariant.safe);
      expect(find.text('Duration'), findsNothing);
    });

    testWidgets('should hide the capture date row when the file has no date', (tester) async {
      // Arrange & Act
      await pump(tester, const GalleryFile(
        id: 'p1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: null,
      ));

      // Assert
      expect(find.text('Captured at'), findsNothing);
      expect(find.text('p1'), findsOneWidget);
    });

    testWidgets('should copy the id to the clipboard', (tester) async {
      // Arrange
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await pump(tester, video);

      // Act
      await tester.tap(find.byTooltip('Copy ID'));
      await tester.pump();

      // Assert
      expect(copied, 'abc-123');
      expect(find.text('Copied'), findsOneWidget);
    });

    // ==================== LOADED DETAILS TESTS ====================

    testWidgets('should show the loading row while the details load', (tester) async {
      // Arrange & Act
      await pump(tester, video);

      // Assert
      expect(find.text('Loading details…'), findsOneWidget);
      expect(find.text('abc-123'), findsOneWidget);
    });

    testWidgets('should show every loaded property', (tester) async {
      // Arrange & Act
      await pump(tester, video, state: FileInfoLoaded(fullInfo));

      // Assert
      expect(find.text('IMG_2041.MOV'), findsOneWidget);
      expect(find.text('Tuesday, January 16, 2024, 03:05'), findsOneWidget);
      expect(find.text('412 MB'), findsOneWidget);
      expect(find.text('1920 × 1080'), findsOneWidget);
      expect(find.text('Japan'), findsOneWidget);
      expect(find.text('Pixel 8'), findsOneWidget);
      expect(find.text('Loading details…'), findsNothing);
    });

    testWidgets('should hide the rows without data', (tester) async {
      // Arrange & Act
      await pump(
        tester,
        video,
        state: const FileInfoLoaded(FileInfo(id: 'abc-123', type: FileType.video, status: FileStatus.pending)),
      );

      // Assert
      for (final label in ['Name', 'Uploaded at', 'Size', 'Dimensions', 'Album', 'Device']) {
        expect(find.text(label), findsNothing, reason: label);
      }
      // Still shows what the gallery already knew.
      expect(find.text('Monday, January 15, 2024, 10:42'), findsOneWidget);
      expect(find.text('1:15'), findsOneWidget);
    });

    testWidgets('should show the size the gallery knew while loading', (tester) async {
      // Arrange & Act
      await pump(tester, video.copyWith(sizeBytes: 3 * 1024 * 1024));

      // Assert
      expect(find.text('3 MB'), findsOneWidget);
    });

    testWidgets('should show the error and retry loading', (tester) async {
      // Arrange
      await pump(tester, video, state: const FileInfoError(NetworkFailure()));

      // Act
      await tester.tap(find.text('Retry'));

      // Assert
      expect(find.text('Loading details…'), findsNothing);
      verify(() => bloc.add(const LoadFileInfo('abc-123'))).called(1);
    });
  });
}
