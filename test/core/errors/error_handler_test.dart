import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';

void main() {
  ApiException apiError(String code) => ApiException(ErrorResponseModel(
        code: code,
        message: 'Mensaje del servidor',
        timestamp: '2026-10-04T12:00:00',
      ));

  group('ErrorHandler', () {
    group('album cover codes', () {
      for (final code in [
        FailureCodes.folderCoversLimitExceeded,
        FailureCodes.folderCoverDuplicated,
        FailureCodes.folderCoverFileNotValid,
        FailureCodes.folderCoverVideoNotAllowed,
        FailureCodes.folderCoverReplaceNotValid,
      ]) {
        test('should map $code to a ValidationFailure with the server message', () {
          // Act
          final failure = ErrorHandler.handleError(apiError(code));

          // Assert
          expect(failure, isA<ValidationFailure>());
          expect(failure.code, code);
          expect(failure.errorResponse?.message, 'Mensaje del servidor');
        });
      }

      test('should keep a FOLDER_NOT_FOUND as not found', () {
        expect(ErrorHandler.handleError(apiError(FailureCodes.folderNotFound)), isA<NotFoundFailure>());
      });
    });

    group('plan codes', () {
      for (final code in [FailureCodes.accountReadOnly, FailureCodes.deviceLimitReached, FailureCodes.devicePaused]) {
        test('should map $code to a PlanLimitFailure with the server message', () {
          final failure = ErrorHandler.handleError(apiError(code));

          expect(failure, isA<PlanLimitFailure>());
          expect(failure.code, code);
          expect(failure.errorResponse?.message, 'Mensaje del servidor');
        });
      }

      test('should map the storage code of the server to a StorageSpaceExceededFailure', () {
        expect(ErrorHandler.handleError(apiError('USER_NOT_HAVE_STORAGE_SPACE')), isA<StorageSpaceExceededFailure>());
      });

      test('should map the device code of the server to a not found failure', () {
        expect(ErrorHandler.handleError(apiError('DEVICE_NOT_LINKED')), isA<NotFoundFailure>());
      });
    });

    group('registration codes', () {
      test('should map a wrong emailed code to a ValidationFailure with the server message', () {
        final failure = ErrorHandler.handleError(apiError(FailureCodes.invalidEmailCode));

        expect(failure, isA<ValidationFailure>());
        expect(failure.code, FailureCodes.invalidEmailCode);
        expect(failure.errorResponse?.message, 'Mensaje del servidor');
      });

      test('should map too many emailed codes to a PermissionDeniedFailure', () {
        expect(ErrorHandler.handleError(apiError(FailureCodes.tooManyEmailCodes)), isA<PermissionDeniedFailure>());
      });

      test('should map an email with an account to an EmailAlreadyExistsFailure', () {
        expect(ErrorHandler.handleError(apiError(FailureCodes.emailAlreadyUsed)), isA<EmailAlreadyExistsFailure>());
      });
    });

    group('second factor of the login', () {
      test('should map a wrong code to a ValidationFailure with the server message', () {
        final failure = ErrorHandler.handleError(apiError(FailureCodes.invalidSecondFactorCode));

        expect(failure, isA<ValidationFailure>());
        expect(failure, isNot(isA<SecondFactorExpiredFailure>()));
        expect(failure.errorResponse?.message, 'Mensaje del servidor');
      });

      test('should map an expired challenge to a SecondFactorExpiredFailure', () {
        final failure = ErrorHandler.handleError(apiError(FailureCodes.secondFactorChallengeExpired));

        expect(failure, isA<SecondFactorExpiredFailure>());
        expect(failure.code, FailureCodes.secondFactorChallengeExpired);
      });

      test('should map a code asked too soon to a PermissionDeniedFailure', () {
        expect(ErrorHandler.handleError(apiError(FailureCodes.secondFactorResendTooSoon)),
            isA<PermissionDeniedFailure>());
      });

      test('should map too many wrong passwords to a PermissionDeniedFailure', () {
        expect(ErrorHandler.handleError(apiError(FailureCodes.tooManyLoginAttempts)),
            isA<PermissionDeniedFailure>());
      });
    });

    test('should return a Failure thrown by a use case as it is', () {
      // Arrange
      const failure = ValidationFailure(code: FailureCodes.folderCoversLimitExceeded);

      // Act & Assert
      expect(ErrorHandler.handleError(failure), same(failure));
    });
  });
}
