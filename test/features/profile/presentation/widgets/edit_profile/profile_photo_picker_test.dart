import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/user_avatar.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/profile_photo_picker.dart';

import '../../../../../helpers/widget_test_helper.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker picker;

  setUpAll(() => registerFallbackValue(ImageSource.gallery));

  setUp(() {
    picker = MockImagePicker();
    when(() => picker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        )).thenAnswer((_) async => null);
  });

  Future<void> pump(WidgetTester tester, {ValueChanged<String?>? onSelected}) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(
      body: Center(
        child: ProfilePhotoPicker(
          name: 'Ana',
          surname: 'López',
          picker: picker,
          onPhotoSelected: onSelected ?? (_) {},
        ),
      ),
    )));
  }

  group('ProfilePhotoPicker', () {
    testWidgets('should show a 96 px avatar with initials and the change button', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      expect(tester.widget<UserAvatar>(find.byType(UserAvatar)).size, 96);
      expect(find.text('AL'), findsOneWidget);
      expect(find.text('Change photo'), findsOneWidget);
    });

    testWidgets('should offer gallery and camera in a sheet', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
    });

    testWidgets('should pick from the camera when chosen', (tester) async {
      // Arrange
      await pump(tester);
      await tester.tap(find.byTooltip('Change photo'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 85,
          )).called(1);
    });

    testWidgets('should not notify when the picker is cancelled', (tester) async {
      // Arrange
      var notified = false;
      await pump(tester, onSelected: (_) => notified = true);
      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();

      // Assert
      expect(notified, isFalse);
    });
  });
}
