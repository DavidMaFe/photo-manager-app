import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/bloc/account_deletion_summary_cubit.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/pages/delete_account_page.dart';

import '../../../../helpers/downloads_test_providers.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockAccountDeletionSummaryCubit extends MockCubit<AccountDeletionSummaryState>
    implements AccountDeletionSummaryCubit {}

void main() {
  late MockAccountDeletionSummaryCubit cubit;
  late GoRouter router;
  const summary = AccountDeletionSummary(files: 1248, storedBytes: 13314398617, albums: 12, devices: 3);

  setUp(() => cubit = MockAccountDeletionSummaryCubit());

  Future<void> pumpPage(WidgetTester tester, AccountDeletionSummaryState state, {Locale locale = const Locale('en')}) async {
    setUpCustomScreenSize(tester, 390, 1200);
    when(() => cubit.state).thenReturn(state);
    when(() => cubit.load()).thenAnswer((_) async {});
    router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('profile'))),
      GoRoute(
        path: '/delete',
        builder: (_, __) => MultiBlocProvider(
          providers: [
            ...downloadsTestProviders(),
            BlocProvider<AccountDeletionSummaryCubit>.value(value: cubit),
          ],
          child: const DeleteAccountPage(saveEverythingRow: Text('save everything')),
        ),
        routes: [
          GoRoute(
            path: 'confirm',
            name: RouteNames.deleteAccountConfirm,
            builder: (_, __) => const Scaffold(body: Text('step 2')),
          ),
        ],
      ),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router, locale: locale));
    router.push('/delete');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('DeleteAccountPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show what is deleted with the summary of the server', (tester) async {
      await pumpPage(tester, AccountDeletionSummaryLoaded(summary));

      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('Before you delete your account'), findsOneWidget);
      expect(find.text('1,248 photos and videos'), findsOneWidget);
      expect(find.text('12 GB stored in the cloud'), findsOneWidget);
      expect(find.text('12 albums'), findsOneWidget);
      expect(find.text('3 devices are unlinked'), findsOneWidget);
      expect(find.text('The photos on your phone are not touched'), findsOneWidget);
      expect(find.text('save everything'), findsOneWidget);
    });

    testWidgets('should show the texts in Spanish', (tester) async {
      await pumpPage(tester, AccountDeletionSummaryLoaded(summary), locale: const Locale('es'));

      expect(find.text('Paso 1 de 2'), findsOneWidget);
      expect(find.text('1.248 fotos y vídeos'), findsOneWidget);
      expect(find.text('12 álbumes'), findsOneWidget);
      expect(find.text('3 dispositivos se desvinculan'), findsOneWidget);
    });

    testWidgets('should go to the second step on Continue', (tester) async {
      await pumpPage(tester, AccountDeletionSummaryLoaded(summary));

      await tester.tap(find.byKey(const ValueKey('delete-account-continue')));
      await tester.pumpAndSettle();

      expect(find.text('step 2'), findsOneWidget);
    });

    testWidgets('should go back to the profile on Keep my account', (tester) async {
      await pumpPage(tester, AccountDeletionSummaryLoaded(summary));

      await tester.tap(find.byKey(const ValueKey('delete-account-keep')));
      await tester.pumpAndSettle();

      expect(find.text('profile'), findsOneWidget);
    });

    // ==================== EDGE CASE TESTS ====================

    testWidgets('should not let continue while the summary loads', (tester) async {
      await pumpPage(tester, AccountDeletionSummaryLoading());

      expect(find.byKey(const ValueKey('delete-account-summary-loading')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('delete-account-continue')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('step 2'), findsNothing);
    });

    testWidgets('should show the error with a retry when the summary fails', (tester) async {
      await pumpPage(tester, AccountDeletionSummaryError(const NetworkFailure()));

      expect(find.text('1,248 photos and videos'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pump(const Duration(milliseconds: 400));

      verify(() => cubit.load()).called(1);
    });

    testWidgets('should say when no device is linked and there is one album', (tester) async {
      await pumpPage(tester,
          AccountDeletionSummaryLoaded(const AccountDeletionSummary(files: 1, storedBytes: 0, albums: 1, devices: 0)));

      expect(find.text('1 photo or video'), findsOneWidget);
      expect(find.text('1 album'), findsOneWidget);
      expect(find.text('No linked devices'), findsOneWidget);
    });
  });
}
