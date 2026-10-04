import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_properties_sheet.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  final video = GalleryFile(
    id: 'abc-123',
    type: FileType.video,
    status: FileStatus.pending,
    durationSeconds: 75,
    capturedAt: DateTime(2024, 1, 15, 10, 42),
  );

  Future<void> pump(WidgetTester tester, GalleryFile file) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(body: FilePropertiesSheet(file: file))));
  }

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
  });
}
