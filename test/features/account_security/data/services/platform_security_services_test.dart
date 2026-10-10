import 'package:credential_manager/credential_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/account_security/data/services/local_auth_device_authenticator.dart';
import 'package:photo_manager_app/features/account_security/data/services/platform_recovery_phrase_exporter.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockCredentialManager extends Mock implements CredentialManager {}

class FakePasswordCredential extends Fake implements PasswordCredential {}

void main() {
  setUpAll(() => registerFallbackValue(FakePasswordCredential()));

  group('LocalAuthDeviceAuthenticator', () {
    late MockLocalAuthentication localAuthentication;
    late LocalAuthDeviceAuthenticator authenticator;

    setUp(() {
      localAuthentication = MockLocalAuthentication();
      authenticator = LocalAuthDeviceAuthenticator(localAuthentication: localAuthentication);
    });

    test('should accept the device PIN or pattern, not only biometrics', () async {
      when(() => localAuthentication.authenticate(
            localizedReason: any(named: 'localizedReason'),
            biometricOnly: any(named: 'biometricOnly'),
          )).thenAnswer((_) async => true);

      expect(await authenticator.authenticate('Confirm it is you'), isTrue);
      verify(() => localAuthentication.authenticate(localizedReason: 'Confirm it is you', biometricOnly: false))
          .called(1);
    });

    test('should answer false when the platform fails', () async {
      when(() => localAuthentication.isDeviceSupported()).thenThrow(Exception('no plugin'));
      when(() => localAuthentication.authenticate(
            localizedReason: any(named: 'localizedReason'),
            biometricOnly: any(named: 'biometricOnly'),
          )).thenThrow(Exception('locked out'));

      expect(await authenticator.isAvailable(), isFalse);
      expect(await authenticator.authenticate('reason'), isFalse);
    });

    test('should tell whether the device has a screen lock', () async {
      when(() => localAuthentication.isDeviceSupported()).thenAnswer((_) async => true);

      expect(await authenticator.isAvailable(), isTrue);
    });
  });

  group('PlatformRecoveryPhraseExporter.saveToPasswordManager', () {
    late MockCredentialManager credentialManager;
    late PlatformRecoveryPhraseExporter exporter;
    final words = List.generate(24, (i) => 'word$i');

    setUp(() {
      credentialManager = MockCredentialManager();
      exporter = PlatformRecoveryPhraseExporter(credentialManager: credentialManager);
      when(() => credentialManager.isSupportedPlatform).thenReturn(true);
      when(() => credentialManager.init(preferImmediatelyAvailableCredentials: any(named: 'preferImmediatelyAvailableCredentials')))
          .thenAnswer((_) async {});
    });

    test('should save the 24 words separated by spaces under the account', () async {
      when(() => credentialManager.savePasswordCredentials(any())).thenAnswer((_) async {});

      expect(await exporter.saveToPasswordManager(account: 'ana@example.com', words: words), isTrue);

      final credential = verify(() => credentialManager.savePasswordCredentials(captureAny())).captured.single
          as PasswordCredential;
      expect(credential.username, 'ana@example.com');
      expect(credential.password, words.join(' '));
    });

    test('should answer false when the user dismisses the dialog', () async {
      when(() => credentialManager.savePasswordCredentials(any())).thenThrow(Exception('cancelled'));

      expect(await exporter.saveToPasswordManager(account: 'ana@example.com', words: words), isFalse);
    });

    test('should answer false on a platform without a password manager', () async {
      when(() => credentialManager.isSupportedPlatform).thenReturn(false);

      expect(await exporter.saveToPasswordManager(account: 'ana@example.com', words: words), isFalse);
      verifyNever(() => credentialManager.savePasswordCredentials(any()));
    });
  });
}
