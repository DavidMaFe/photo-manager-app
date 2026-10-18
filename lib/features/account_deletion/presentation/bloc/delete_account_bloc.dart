import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/account_deletion/domain/use_cases/delete_account_use_case.dart';

abstract class DeleteAccountEvent {}

class DeleteAccountSubmitted extends DeleteAccountEvent {
  final String password;

  DeleteAccountSubmitted({required this.password});
}

abstract class DeleteAccountState {}

class DeleteAccountInitial extends DeleteAccountState {}

class DeleteAccountLoading extends DeleteAccountState {}

class DeleteAccountSuccess extends DeleteAccountState {}

class DeleteAccountError extends DeleteAccountState {
  final Failure failure;

  DeleteAccountError(this.failure);
}

/// Second step of the deletion: the password and the confirmation word.
class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  static const int minimumLoadingDuration = 800;

  final DeleteAccountUseCase deleteAccountUseCase;

  DeleteAccountBloc({required this.deleteAccountUseCase}) : super(DeleteAccountInitial()) {
    on<DeleteAccountSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(DeleteAccountSubmitted event, Emitter<DeleteAccountState> emit) async {
    emit(DeleteAccountLoading());
    final stopwatch = Stopwatch()..start();
    try {
      await deleteAccountUseCase(password: event.password);
      await _waitForLoading(stopwatch);
      emit(DeleteAccountSuccess());
    } catch (e) {
      await _waitForLoading(stopwatch);
      emit(DeleteAccountError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> _waitForLoading(Stopwatch stopwatch) async {
    stopwatch.stop();
    final remaining = minimumLoadingDuration - stopwatch.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
  }
}
