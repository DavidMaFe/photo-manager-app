import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/bip39/bip39_english.dart';
import 'package:photo_manager_app/core/crypto/domain/bip39/bip39_spanish.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

Uint8List filled(int byte) => Uint8List.fromList(List.filled(32, byte));

Uint8List fromHex(String hex) =>
    Uint8List.fromList(List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));

void main() {
  group('RecoveryPhrase', () {
    group('wordlists', () {
      test('should have the 2048 words of the official BIP39 lists', () {
        expect(bip39English.length, 2048);
        expect(bip39Spanish.length, 2048);
        expect(bip39English.first, 'abandon');
        expect(bip39English.last, 'zoo');
        // The official Spanish list stores accents decomposed
        expect(unorm.nfc(bip39Spanish.first), 'ábaco');
      });
    });

    group('encode', () {
      // Official BIP39 vectors for 256-bit entropy (https://github.com/trezor/python-mnemonic/blob/master/vectors.json)
      final officialVectors = {
        '00': '${'abandon ' * 23}art',
        '7f': 'legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful '
            'legal winner thank year wave sausage worth title',
        '80': 'letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic '
            'avoid letter advice cage absurd amount doctor acoustic bless',
        'ff': '${'zoo ' * 23}vote',
      };

      for (final entry in officialVectors.entries) {
        test('should match the official English vector for 0x${entry.key}...', () {
          final words = RecoveryPhrase.encode(filled(int.parse(entry.key, radix: 16)), RecoveryPhraseLanguage.english);

          expect(words.join(' '), entry.value);
        });
      }

      test('should match an official vector with mixed entropy', () {
        final words = RecoveryPhrase.encode(
            fromHex('68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c'), RecoveryPhraseLanguage.english);

        expect(words.join(' '),
            'hamster diagram private dutch cause delay private meat slide toddler razor book happy fancy gospel tennis '
            'maple dilemma loan word shrug inflict delay length');
      });

      test('should give 24 Spanish words', () {
        final words = RecoveryPhrase.encode(filled(0x00), RecoveryPhraseLanguage.spanish);

        expect(words.length, 24);
        expect(words.first, 'ábaco');
      });

      test('should reject a key that is not 32 bytes', () {
        expect(() => RecoveryPhrase.encode(Uint8List(16), RecoveryPhraseLanguage.english), throwsArgumentError);
      });
    });

    group('decode', () {
      final key = fromHex('68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c');

      test('should recover the key from English words', () {
        final words = RecoveryPhrase.encode(key, RecoveryPhraseLanguage.english);

        expect(RecoveryPhrase.decode(words), key);
      });

      test('should recover the key from Spanish words', () {
        final words = RecoveryPhrase.encode(key, RecoveryPhraseLanguage.spanish);

        expect(RecoveryPhrase.decode(words), key);
      });

      test('should accept Spanish words without accents, in capitals and with spaces', () {
        final words = RecoveryPhrase.encode(filled(0x00), RecoveryPhraseLanguage.spanish)
            .map((word) => '  ${word.replaceAll('á', 'a').toUpperCase()} ')
            .toList();

        expect(RecoveryPhrase.decode(words), filled(0x00));
      });

      test('should throw FormatException when a word is mistyped (checksum)', () {
        final words = RecoveryPhrase.encode(key, RecoveryPhraseLanguage.english);
        words[5] = words[5] == 'abandon' ? 'ability' : 'abandon';

        expect(() => RecoveryPhrase.decode(words), throwsFormatException);
      });

      test('should throw FormatException with an unknown word', () {
        final words = RecoveryPhrase.encode(key, RecoveryPhraseLanguage.english);
        words[0] = 'notaword';

        expect(() => RecoveryPhrase.decode(words), throwsFormatException);
      });

      test('should throw FormatException with fewer than 24 words', () {
        final words = RecoveryPhrase.encode(key, RecoveryPhraseLanguage.english).sublist(0, 23);

        expect(() => RecoveryPhrase.decode(words), throwsFormatException);
      });

      test('should ignore empty entries', () {
        final words = [...RecoveryPhrase.encode(key, RecoveryPhraseLanguage.english), '', '  '];

        expect(RecoveryPhrase.decode(words), key);
      });
    });
  });
}
