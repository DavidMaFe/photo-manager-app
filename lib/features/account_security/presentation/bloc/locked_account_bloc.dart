import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/locked_account_use_cases.dart';

// ==================== EVENTS ====================

abstract class LockedAccountEvent {}

class LockedAccountStatusRequested extends LockedAccountEvent {}

class UnlockWithWordsRequested extends LockedAccountEvent {
  final String password;
  final List<String> words;

  UnlockWithWordsRequested({required this.password, required this.words});
}

class UnlockWithDeviceRequested extends LockedAccountEvent {
  final String password;

  UnlockWithDeviceRequested({required this.password});
}

class NewKeyRequested extends LockedAccountEvent {
  final String password;
  final RecoveryPhraseLanguage language;

  NewKeyRequested({required this.password, required this.language});
}

// ==================== STATES ====================

abstract class LockedAccountState {}

class LockedAccountLoading extends LockedAccountState {}

class LockedAccountLoaded extends LockedAccountState {
  final LockedAccountStatus status;
  final bool working;

  LockedAccountLoaded(this.status, {this.working = false});
}

/// Some locked versions were unlocked; [accountUsable] says whether there is a current key now.
class LockedAccountUnlocked extends LockedAccountState {
  final List<int> versions;
  final bool accountUsable;

  LockedAccountUnlocked(this.versions, {required this.accountUsable});
}

class LockedAccountNewKeyCreated extends LockedAccountState {
  final List<String> words;

  LockedAccountNewKeyCreated(this.words);
}

class LockedAccountError extends LockedAccountState {
  final Failure failure;
  final LockedAccountStatus? status;

  LockedAccountError(this.failure, this.status);
}

// ==================== BLOC ====================

/// Locked account page (docs/e2ee-spec.md, section 8.6): unlock with the old 24 words, from a device that still
/// holds the keys, or start with a new key. Nothing is ever deleted.
class LockedAccountBloc extends Bloc<LockedAccountEvent, LockedAccountState> {
  final GetLockedAccountStatusUseCase getStatusUseCase;
  final UnlockWithRecoveryPhraseUseCase unlockWithRecoveryPhraseUseCase;
  final UnlockWithDeviceKeysUseCase unlockWithDeviceKeysUseCase;
  final CreateNewKeyVersionUseCase createNewKeyVersionUseCase;

  LockedAccountStatus? _status;

  LockedAccountBloc({
    required this.getStatusUseCase,
    required this.unlockWithRecoveryPhraseUseCase,
    required this.unlockWithDeviceKeysUseCase,
    required this.createNewKeyVersionUseCase,
  }) : super(LockedAccountLoading()) {
    on<LockedAccountStatusRequested>(_onStatusRequested);
    on<UnlockWithWordsRequested>((event, emit) => _unlock(emit,
        () => unlockWithRecoveryPhraseUseCase(password: event.password, words: event.words)));
    on<UnlockWithDeviceRequested>((event, emit) => _unlock(emit,
        () => unlockWithDeviceKeysUseCase(password: event.password)));
    on<NewKeyRequested>(_onNewKeyRequested);
  }

  Future<void> _onStatusRequested(LockedAccountStatusRequested event, Emitter<LockedAccountState> emit) async {
    emit(LockedAccountLoading());
    try {
      _status = await getStatusUseCase();
      emit(LockedAccountLoaded(_status!));
    } catch (e) {
      emit(LockedAccountError(ErrorHandler.handleError(e), _status));
    }
  }

  Future<void> _unlock(Emitter<LockedAccountState> emit, Future<List<int>> Function() unlock) async {
    if (_status != null) {
      emit(LockedAccountLoaded(_status!, working: true));
    }
    try {
      final versions = await unlock();
      _status = await getStatusUseCase();
      emit(LockedAccountUnlocked(versions, accountUsable: !_status!.keys.accountLocked));
    } catch (e) {
      emit(LockedAccountError(ErrorHandler.handleError(e), _status));
    }
  }

  Future<void> _onNewKeyRequested(NewKeyRequested event, Emitter<LockedAccountState> emit) async {
    if (_status != null) {
      emit(LockedAccountLoaded(_status!, working: true));
    }
    try {
      final words = await createNewKeyVersionUseCase(password: event.password, language: event.language);
      emit(LockedAccountNewKeyCreated(words));
    } catch (e) {
      emit(LockedAccountError(ErrorHandler.handleError(e), _status));
    }
  }
}
