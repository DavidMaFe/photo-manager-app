import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_menu_item.dart';
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

  group('ProfileMenuItem', () {
    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(makeTestableWidget(
        ProfileMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () => tapped = true,
        ),
      ));

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should display multiple menu items correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        Column(
          children: [
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.devices_outlined,
              title: 'My Devices',
              subtitle: '2 devices connected',
              onTap: () {},
            ),
          ],
        ),
      ));

      // Assert
      expect(find.byType(ProfileMenuItem), findsNWidgets(2));
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('My Devices'), findsOneWidget);
    });
  });
}
