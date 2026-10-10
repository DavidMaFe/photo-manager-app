import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';

abstract class VerifyRecoveryPhraseEvent {}

class VerifyRecoveryPhraseStarted extends VerifyRecoveryPhraseEvent {}

class VerifyWordsSubmitted extends VerifyRecoveryPhraseEvent {
  final Map<int, String> typedByPosition;
  final RecoveryPhraseLanguage language;

  VerifyWordsSubmitted(this.typedByPosition, this.language);
}

class VerifyFullPhraseSubmitted extends VerifyRecoveryPhraseEvent {
  final List<String> words;

  VerifyFullPhraseSubmitted(this.words);
}

abstract class VerifyRecoveryPhraseState {}

class VerifyRecoveryPhraseLoading extends VerifyRecoveryPhraseState {}

/// This device keeps the recovery key: ask for the words at [positions] (0-based).
class VerifyAskWords extends VerifyRecoveryPhraseState {
  final List<int> positions;
  final bool wrong;
  final bool working;

  VerifyAskWords(this.positions, {this.wrong = false, this.working = false});
}

/// No local copy: ask for the full phrase, checked against the server.
class VerifyAskFullPhrase extends VerifyRecoveryPhraseState {
  final bool working;
  final Failure? failure;

  VerifyAskFullPhrase({this.working = false, this.failure});
}

class VerifyRecoveryPhraseSuccess extends VerifyRecoveryPhraseState {}

/// Checks that the user still has the 24 words; a successful check moves the reminders forward.
class VerifyRecoveryPhraseBloc extends Bloc<VerifyRecoveryPhraseEvent, VerifyRecoveryPhraseState> {
  final VerifyRecoveryWordsUseCase verifyUseCase;
  final RecoveryReminderUseCase reminderUseCase;

  List<int> _positions = const [];

  VerifyRecoveryPhraseBloc({required this.verifyUseCase, required this.reminderUseCase})
      : super(VerifyRecoveryPhraseLoading()) {
    on<VerifyRecoveryPhraseStarted>(_onStarted);
    on<VerifyWordsSubmitted>(_onWordsSubmitted);
    on<VerifyFullPhraseSubmitted>(_onFullPhraseSubmitted);
  }

  Future<void> _onStarted(VerifyRecoveryPhraseStarted event, Emitter<VerifyRecoveryPhraseState> emit) async {
    if (await verifyUseCase.hasLocalCopy()) {
      _positions = verifyUseCase.positionsToAsk();
      emit(VerifyAskWords(_positions));
    } else {
      emit(VerifyAskFullPhrase());
    }
  }

  Future<void> _onWordsSubmitted(VerifyWordsSubmitted event, Emitter<VerifyRecoveryPhraseState> emit) async {
    emit(VerifyAskWords(_positions, working: true));
    if (await verifyUseCase.checkWords(event.typedByPosition, event.language)) {
      await reminderUseCase.completeVerification();
      emit(VerifyRecoveryPhraseSuccess());
    } else {
      emit(VerifyAskWords(_positions, wrong: true));
    }
  }

  Future<void> _onFullPhraseSubmitted(VerifyFullPhraseSubmitted event, Emitter<VerifyRecoveryPhraseState> emit) async {
    emit(VerifyAskFullPhrase(working: true));
    try {
      await verifyUseCase.verifyFullPhrase(event.words);
      await reminderUseCase.completeVerification();
      emit(VerifyRecoveryPhraseSuccess());
    } catch (e) {
      emit(VerifyAskFullPhrase(failure: ErrorHandler.handleError(e)));
    }
  }
}
