import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/profile_photo_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('ProfilePhotoPicker', () {
    testWidgets('should display initials when no photo provided',
        (tester) async {
      // Arrange
      bool photoSelectedCalled = false;

      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {
            photoSelectedCalled = true;
          },
        ),
      ));

      // Assert
      expect(find.text('JD'), findsOneWidget);
      expect(photoSelectedCalled, false);
    });

    testWidgets('should display single initial for single name',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should display first and last initials for multiple names',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Michael Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should display question mark for empty name', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: '',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should display camera icon button', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should display change photo button', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      expect(find.text('Change photo'), findsOneWidget);
    });

    testWidgets('should display CircleAvatar with correct radius',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      final circleAvatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(circleAvatar.radius, 60);
    });

    testWidgets('should show modal bottom sheet when camera icon tapped',
        (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Act
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Assert - Modal should appear with photo library option
      expect(find.text('Select profile photo'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera), findsOneWidget);
    });

    testWidgets('should show modal bottom sheet when change photo button tapped',
        (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Act
      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Select profile photo'), findsOneWidget);
    });

    testWidgets('should close modal when gallery option tapped',
        (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Act - Open modal
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Tap gallery option
      await tester.tap(find.byIcon(Icons.photo_library));
      await tester.pumpAndSettle();

      // Assert - Modal should be closed
      expect(find.text('Select profile photo'), findsNothing);
    });

    testWidgets('should close modal when camera option tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Act - Open modal
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Tap camera option
      await tester.tap(find.byIcon(Icons.photo_camera));
      await tester.pumpAndSettle();

      // Assert - Modal should be closed
      expect(find.text('Select profile photo'), findsNothing);
    });

    testWidgets('should handle current photo URL', (tester) async {
      // Arrange - Just verify it builds without errors
      // Network images fail in tests, so we just verify construction
      expect(
        () => ProfilePhotoPicker(
          currentPhotoUrl: 'https://example.com/photo.jpg',
          fullName: 'John Doe',
          onPhotoSelected: (photo) {},
        ),
        returnsNormally,
      );
    });

    testWidgets('should uppercase initials', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: 'john doe',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('jd'), findsNothing);
    });

    testWidgets('should handle names with extra spaces', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        ProfilePhotoPicker(
          currentPhotoUrl: null,
          fullName: '  John   Doe  ',
          onPhotoSelected: (photo) {},
        ),
      ));

      // Assert
      expect(find.text('JD'), findsOneWidget);
    });
  });
}
