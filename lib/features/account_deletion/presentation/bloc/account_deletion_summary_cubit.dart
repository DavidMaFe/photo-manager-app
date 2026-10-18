import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/domain/use_cases/get_account_deletion_summary_use_case.dart';

abstract class AccountDeletionSummaryState {}

class AccountDeletionSummaryLoading extends AccountDeletionSummaryState {}

class AccountDeletionSummaryLoaded extends AccountDeletionSummaryState {
  final AccountDeletionSummary summary;

  AccountDeletionSummaryLoaded(this.summary);
}

class AccountDeletionSummaryError extends AccountDeletionSummaryState {
  final Failure failure;

  AccountDeletionSummaryError(this.failure);
}

/// What deleting the account removes, for the first step of the deletion.
class AccountDeletionSummaryCubit extends Cubit<AccountDeletionSummaryState> {
  final GetAccountDeletionSummaryUseCase getSummary;

  AccountDeletionSummaryCubit({required this.getSummary}) : super(AccountDeletionSummaryLoading());

  Future<void> load() async {
    emit(AccountDeletionSummaryLoading());
    try {
      emit(AccountDeletionSummaryLoaded(await getSummary()));
    } catch (e) {
      emit(AccountDeletionSummaryError(ErrorHandler.handleError(e)));
    }
  }
}
