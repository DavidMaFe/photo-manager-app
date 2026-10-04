import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:photo_manager_app/features/profile/presentation/pages/edit_profile_page.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}

class FakeProfileEvent extends Fake implements ProfileEvent {}

void main() {
  late MockProfileBloc bloc;

  setUpAll(() => registerFallbackValue(FakeProfileEvent()));

  setUp(() {
    bloc = MockProfileBloc();
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.state).thenReturn(ProfileLoaded(TestProfiles.emptyStorageProfile));
    when(() => bloc.close()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, {bool scrollToPassword = false, double height = 844}) async {
    setUpCustomScreenSize(tester, 390, height);
    await tester.pumpWidget(makeTestableWidgetWithBloc<ProfileBloc>(
      bloc: bloc,
      child: EditProfilePage(scrollToPassword: scrollToPassword),
    ));
    await tester.pump();
  }

  group('EditProfilePage', () {
    testWidgets('should show the top bar, sections and anchored save button', (tester) async {
      // Arrange & Act
      await pump(tester, height: 1400);

      // Assert
      expect(find.byType(SecondaryTopBar), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('DETAILS'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      final save = tester.getRect(find.widgetWithText(AppButton, 'Save changes'));
      expect(save.bottom, greaterThan(1400 - 80));
    });

    testWidgets('should prefill the name fields', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      final name = tester.widget<TextFormField>(find.byType(TextFormField).first);
      expect(name.controller!.text, 'New');
    });

    testWidgets('should update the profile when the name changes', (tester) async {
      // Arrange
      await pump(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Ana');

      // Act
      await tester.tap(find.widgetWithText(AppButton, 'Save changes'));
      await tester.pump();

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<UpdateProfileRequested>().having((e) => e.name, 'name', 'Ana'));
    });

    testWidgets('should scroll to the password section when asked', (tester) async {
      // Arrange & Act
      await pump(tester, scrollToPassword: true);
      await tester.pump(const Duration(milliseconds: 400));

      // Assert
      final label = tester.getRect(find.text('PASSWORD'));
      expect(label.top, lessThan(844 / 2));
    });

    testWidgets('should show loading on the save button while updating', (tester) async {
      // Arrange
      when(() => bloc.stream).thenAnswer((_) => Stream.value(ProfileUpdating()));

      // Act
      await pump(tester);
      await tester.pump();

      // Assert
      expect(tester.widget<AppButton>(find.byType(AppButton).last).loading, isTrue);
    });
  });
}
