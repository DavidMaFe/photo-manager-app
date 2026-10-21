import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';

void main() {
  group('TotpSetUp', () {
    test('should group the secret in fours to type it', () {
      const setUp = TotpSetUp(secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ', otpauthUri: 'otpauth://totp/x');

      expect(setUp.groupedSecret, 'GEZD GNBV GY3T QOJQ GEZD GNBV GY3T QOJQ');
    });

    test('should keep a last group shorter than four', () {
      expect(const TotpSetUp(secret: 'ABCDEF', otpauthUri: '').groupedSecret, 'ABCD EF');
    });
  });
}
